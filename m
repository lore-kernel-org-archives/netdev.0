From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next 00/26] bonding/team offload + mlxsw implementation
Date: Wed, 2 Dec 2015 10:25:14 +0200
Message-ID: <CAJ3xEMgLti3KWEZoB4vp11gy=-xfveThf99K9x-3ZtMjdRMqCg@mail.gmail.com>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
	<20151201144300.GB2165@nanopsycho.orion>
	<CAJ3xEMhMACJe_iK4PTrGwGFHzgGM=ccNKjVBoC6SUfCo0w7xFQ@mail.gmail.com>
	<20151201151243.GC2165@nanopsycho.orion>
	<CAJ3xEMjRQQoo=uU0qQ5Z9UmvS0_QjB2q_LUrpfBWLtTpHhd3qw@mail.gmail.com>
	<20151201164719.GA2548@nanopsycho>
	<CAJ3xEMiSA70nDsBWUmv=J6Cy2rt4+iNTg+4Yeqy=810etVAPZw@mail.gmail.com>
	<20151202075822.GD2355@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>, yotamg@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>, pjonnala@broadcom.com,
	Jay Vosburgh <j.vosburgh@gmail.com>, vfalico@gmail.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	john fastabend <john.fastabend@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:33431 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757500AbbLBIZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 03:25:15 -0500
Received: by iouu10 with SMTP id u10so38818252iou.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 00:25:15 -0800 (PST)
In-Reply-To: <20151202075822.GD2355@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 2, 2015 at 9:58 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Wed, Dec 02, 2015 at 06:53:35AM CET, gerlitz.or@gmail.com wrote:

>>Another question relates to users bonding/teaming netdevice ports from
>>different HW switches, or of two vlans over ports from the same HW switch.

>>This is something that AFAIK not supported by HW -- do we want to
>>disallow that?
>>what layer in the kernel we want to enforce that limitation? team/bond
>>or switchdev core or the switchdev HW driver?


> It is not handled at the moment. In can be easily disallowed by driver.

what about the case of LAG + VLANs, what you think fits better HW switches?
what would be currently supported, bonding vlans or vlan a bond?

For me the 1st one (below) makes more sense

bond b0 -->
     vlan A.X --> switchdev port A
     vlan B.X --> switchdev port B

vlan b0.X --> bond b0 -->
                      switchdev port A
                      switchdev port B

Or.
