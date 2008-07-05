From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Sat, 05 Jul 2008 14:23:19 +0200
Message-ID: <486F67B7.9040304@firstfloor.org>
References: <486E2260.5050503@garzik.org>	 <1215178035.10393.763.camel@pmac.infradead.org>	 <20080704141014.GA23215@mit.edu> <s5habgxloct.wl%tiwai@suse.de>	 <486E3622.1000900@suse.de> <1215182557.10393.808.camel@pmac.infradead.org>	 <20080704231322.GA4410@dspnet.fr.eu.org> <s5h4p746am3.wl%tiwai@suse.de>	 <20080705105317.GA44773@dspnet.fr.eu.org> <486F596C.8050109@firstfloor.org>	 <20080705120221.GC44773@dspnet.fr.eu.org> <486F6494.8020108@firstfloor.org> <1215260166.10393.816.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Olivier Galibert <galibert@pobox.com>,
	Takashi Iwai <tiwai@suse.de>, Hannes Reinecke <hare@suse.de>,
	Theodore Tso <tytso@mit.edu>, Jeff Garzik <jeff@garzik.org>,
	David Miller <davem@davemloft.net>, hugh@veritas.com,
	akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:39304 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbYGEMXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2008 08:23:23 -0400
In-Reply-To: <1215260166.10393.816.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse wrote:
> On Sat, 2008-07-05 at 14:09 +0200, Andi Kleen wrote:
>> Olivier Galibert wrote:
>>> On Sat, Jul 05, 2008 at 01:22:20PM +0200, Andi Kleen wrote:
>>>> Many distribution have some way for separate kernel module packages.
>>>> It's essentially the same problem so it should be already solved
>>>> in some way.
>>> Errr, no.  Modules go in /lib/modules/`uname -r`, so no conflict.
>> Well that's the only sane way to store the firmware anyways (otherwise
>> you could never keep kernel versions which need different firmware installed)
> 
> It almost never happens that you have kernel versions which _need_
> different firmware installed. In almost all cases, the older driver will
> continue to work just fine with the newer firmware (and its bug-fixes).

That's a lot of "should" and "in most cases" and "in a ideal world". What happens
when the new firmware is buggy for example and prevents booting of the system?
And in the cases where it doesn't work like you describe?

Simply overwriting it means there would be no simple way back.

Even if it breaks for only 1% of the users that would be pretty bad for Linux.

Besides it means the possible combinations that have to be tested
increases significantly.

Doesn't sound like a good plan to me. Besides the problems
that it would causes for package management of course (you would
force separate packages on everybody versus just keeping the firmware
in the kernel package)

-Andi
