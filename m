From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/26] bonding/team offload + mlxsw
 implementation
Date: Tue, 1 Dec 2015 17:47:19 +0100
Message-ID: <20151201164719.GA2548@nanopsycho>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
 <20151201144300.GB2165@nanopsycho.orion>
 <CAJ3xEMhMACJe_iK4PTrGwGFHzgGM=ccNKjVBoC6SUfCo0w7xFQ@mail.gmail.com>
 <20151201151243.GC2165@nanopsycho.orion>
 <CAJ3xEMjRQQoo=uU0qQ5Z9UmvS0_QjB2q_LUrpfBWLtTpHhd3qw@mail.gmail.com>
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
Received: from mail-wm0-f46.google.com ([74.125.82.46]:33638 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754713AbbLAQrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 11:47:23 -0500
Received: by wmec201 with SMTP id c201so214685045wme.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 08:47:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMjRQQoo=uU0qQ5Z9UmvS0_QjB2q_LUrpfBWLtTpHhd3qw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Dec 01, 2015 at 05:35:43PM CET, gerlitz.or@gmail.com wrote:
>On Tue, Dec 1, 2015 at 5:12 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Tue, Dec 01, 2015 at 04:06:23PM CET, gerlitz.or@gmail.com wrote:
>>>On Tue, Dec 1, 2015 at 4:43 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> Tue, Dec 01, 2015 at 02:48:38PM CET, jiri@resnulli.us wrote:
>
>>>>>This patchset introduces needed infrastructure for link aggregation
>>>>>offload - for both team and bonding. It also implements the offload
>>>>>in mlxsw driver.
>
>>>I didn't see any changes to switchdev.h, can you elaborate on that please.
>
>> Correct. This patchset does not extend switchdev api. The extension is
>> done for netdev notifiers. It seems natural and correct.
>> As we discussed already with John on a different thread, it makes sense
>> for non-switchdev drivers to benefit from this extensions as well.
>
>This is understood.
>
>However, the point which is still not clear to me related to the LAG /
>switchdev object model.
>
>All of FDB/VLAN/FIB switchdev objects have corresponding software counterparts
>in the kernel --- what's the case for LAG? the software construct is
>bond or team
>instance, shouldn't there  be a modeling of the HW LAG object in switchdev?

No need for that, what that would be good for?

Switchdev iface (most of it) works with struct net_device. Does not matter
if that is the port netdev direclty, or if it is team/bonding netdev.
It falls into the picture very nicely.
