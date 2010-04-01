From: Patrick McHardy <kaber@trash.net>
Subject: Re: XT_ALIGN changed to use ALIGN breaks iproute2
Date: Thu, 01 Apr 2010 12:50:56 +0200
Message-ID: <4BB47A90.5040605@trash.net>
References: <20100330092829.GA3106@amd64.fatal.se> <b6fcc0a1003300615k54092120nfb8b5378771657@mail.gmail.com> <1269961278.2174.11.camel@achroite.uk.solarflarecom.com> <20100330082902.6d64d21d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andreas Henriksson <andreas@fatal.se>, jamal <hadi@cyberus.ca>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49719 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755148Ab0DAKu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 06:50:58 -0400
In-Reply-To: <20100330082902.6d64d21d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Tue, 30 Mar 2010 16:01:18 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
>> On Tue, 2010-03-30 at 16:15 +0300, Alexey Dobriyan wrote:
>>> On Tue, Mar 30, 2010 at 12:28 PM, Andreas Henriksson <andreas@fatal.se> wrote:
>>>> You updated the kernel header include/linux/netfilter/x_tables.h
>>>> in torvalds/linux-2.6.git commit 42107f5009da223daa800d6da6904d77297ae829
>>>> with the comment "Use ALIGN() macro while I'm at it for same types.".
>>>>
>>>> When this header was synced into iproute2 the build broke because the
>>>> ALIGN macro apparently only is defined in kernel headers.
>>>>
>>>> (For iproute2 the problem was introduced in
>>>> 8ecdcce08319d0e39b0d32c1d17db3f69d85a35c and found by Stephen
>>>> and worked around in 609ceb807deba8e23 and edaaa11e5a3cf2c9c1a39)
>>>>
>>>> I'm guessing the problem in the iproute2 header sync is just a heads
>>>> up for what's going to happen when distributions updates their
>>>> system headers to match linux 2.6.33.
>>>>
>>>>
>>>> Could someone who knows how the userspace version of the kernel
>>>> headers are generated please find a suitable solution?
>>> We can export ALIGN to userspace, but the name is so generic,
>>> so it's not clear what breakage more risky.
> 
> I put a hack in m_xt.c to keep iproute2 building.
> But this is a temporary workaround until you guys figure out the
> right answer.

I can't think of anything but to restore the XT_ALIGN macro.
We could add a XT_ALIGN definition to xtables.h, but that might
still leave problems for other users.

Alexey, do you have any better suggestions?

