From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/26] bonding/team offload + mlxsw
 implementation
Date: Wed, 2 Dec 2015 09:25:02 +0100
Message-ID: <20151202082502.GE2355@nanopsycho.orion>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
 <20151201144300.GB2165@nanopsycho.orion>
 <CAJ3xEMhMACJe_iK4PTrGwGFHzgGM=ccNKjVBoC6SUfCo0w7xFQ@mail.gmail.com>
 <20151201151243.GC2165@nanopsycho.orion>
 <CAJ3xEMjRQQoo=uU0qQ5Z9UmvS0_QjB2q_LUrpfBWLtTpHhd3qw@mail.gmail.com>
 <20151201164719.GA2548@nanopsycho>
 <CAJ3xEMiSA70nDsBWUmv=J6Cy2rt4+iNTg+4Yeqy=810etVAPZw@mail.gmail.com>
 <20151202075822.GD2355@nanopsycho.orion>
 <CAJ3xEMiBhTiJFv_znngAg3+REk38w_3G-dr8rXCmGYeT2xketg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:34485 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756088AbbLBIZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 03:25:04 -0500
Received: by wmvv187 with SMTP id v187so242900345wmv.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 00:25:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMiBhTiJFv_znngAg3+REk38w_3G-dr8rXCmGYeT2xketg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 02, 2015 at 09:21:37AM CET, gerlitz.or@gmail.com wrote:
>On Wed, Dec 2, 2015 at 9:58 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Wed, Dec 02, 2015 at 06:53:35AM CET, gerlitz.or@gmail.com wrote:
>
>>> Another question relates to users bonding/teaming netdevice ports from
>>> different HW switches, or of two vlans over ports from the same HW switch.
>
>>> This is something that AFAIK not supported by HW -- do we want to disallow that?
>>> what layer in the kernel we want to enforce that limitation? team/bond
>>> or switchdev core or the switchdev HW driver?
>
>> It is not handled at the moment. In can be easily disallowed by driver.
>
>what about the case of LAG + VLANs, what would be currently supported,
>bonding vlans or vlan a bond?
>
>
>bond b0 -->
>     vlan A.X --> switchdev port A
>     vlan B.X --> switchdev port B
>
>vlan b0.X --> bond b0 -->
>vlan --> switchdev port

- vlan on top of bond/team (bridge vlan) is currently supported.
- Ido is working on support of vlan device on top of bond/team. This
  will be most likely matter of the next patchset, quite soon.
- bond/team on top of vlan is not supported by hw.
