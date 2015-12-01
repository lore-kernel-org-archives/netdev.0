From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next 00/26] bonding/team offload + mlxsw implementation
Date: Tue, 1 Dec 2015 18:35:43 +0200
Message-ID: <CAJ3xEMjRQQoo=uU0qQ5Z9UmvS0_QjB2q_LUrpfBWLtTpHhd3qw@mail.gmail.com>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
	<20151201144300.GB2165@nanopsycho.orion>
	<CAJ3xEMhMACJe_iK4PTrGwGFHzgGM=ccNKjVBoC6SUfCo0w7xFQ@mail.gmail.com>
	<20151201151243.GC2165@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36971 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752796AbbLAQfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 11:35:44 -0500
Received: by igcto18 with SMTP id to18so10553449igc.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 08:35:43 -0800 (PST)
In-Reply-To: <20151201151243.GC2165@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 1, 2015 at 5:12 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Dec 01, 2015 at 04:06:23PM CET, gerlitz.or@gmail.com wrote:
>>On Tue, Dec 1, 2015 at 4:43 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Tue, Dec 01, 2015 at 02:48:38PM CET, jiri@resnulli.us wrote:

>>>>This patchset introduces needed infrastructure for link aggregation
>>>>offload - for both team and bonding. It also implements the offload
>>>>in mlxsw driver.

>>I didn't see any changes to switchdev.h, can you elaborate on that please.

> Correct. This patchset does not extend switchdev api. The extension is
> done for netdev notifiers. It seems natural and correct.
> As we discussed already with John on a different thread, it makes sense
> for non-switchdev drivers to benefit from this extensions as well.

This is understood.

However, the point which is still not clear to me related to the LAG /
switchdev object model.

All of FDB/VLAN/FIB switchdev objects have corresponding software counterparts
in the kernel --- what's the case for LAG? the software construct is
bond or team
instance, shouldn't there  be a modeling of the HW LAG object in switchdev?

Or.
