From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/26] bonding/team offload + mlxsw
 implementation
Date: Tue, 1 Dec 2015 16:12:43 +0100
Message-ID: <20151201151243.GC2165@nanopsycho.orion>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
 <20151201144300.GB2165@nanopsycho.orion>
 <CAJ3xEMhMACJe_iK4PTrGwGFHzgGM=ccNKjVBoC6SUfCo0w7xFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>, yotamg@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>, pjonnala@broadcom.com,
	j.vosburgh@gmail.com, vfalico@gmail.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	john fastabend <john.fastabend@gmail.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36808 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755637AbbLAPMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 10:12:46 -0500
Received: by wmww144 with SMTP id w144so177120792wmw.1
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 07:12:44 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMhMACJe_iK4PTrGwGFHzgGM=ccNKjVBoC6SUfCo0w7xFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Dec 01, 2015 at 04:06:23PM CET, gerlitz.or@gmail.com wrote:
>On Tue, Dec 1, 2015 at 4:43 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Tue, Dec 01, 2015 at 02:48:38PM CET, jiri@resnulli.us wrote:
>>>From: Jiri Pirko <jiri@mellanox.com>
>>>
>>>This patchset introduces needed infrastructure for link aggregation
>>>offload - for both team and bonding. It also implements the offload
>>>in mlxsw driver.
>
>Hi Jiri,
>
>I didn't see any changes to switchdev.h, can you elaborate on that please.

Correct. This patchset does not extend switchdev api. The extension is
done for netdev notifiers. It seems natural and correct.

As we discussed already with John on a different thread, it makes sense
for non-switchdev drivers to benefit from this extensions as well.
