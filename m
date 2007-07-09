From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] the overdue eepro100 removal
Date: Mon, 9 Jul 2007 19:52:51 +0200
Message-ID: <20070709175251.GG3492@stusta.de>
References: <20070701202139.GM10869@stusta.de> <46894BD5.9080609@tmr.com> <46897212.30104@intel.com> <468D15F4.6020106@tmr.com> <20070709125208.GZ3492@stusta.de> <4692701B.3030506@tmr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	saw@saw.sw.com.sg, Linus Torvalds <torvalds@linux-foundation.org>
To: Bill Davidsen <davidsen@tmr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:55778 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754198AbXGIRwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 13:52:19 -0400
Content-Disposition: inline
In-Reply-To: <4692701B.3030506@tmr.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 09, 2007 at 01:27:55PM -0400, Bill Davidsen wrote:
> Adrian Bunk wrote:
>> On Thu, Jul 05, 2007 at 12:01:56PM -0400, Bill Davidsen wrote:
>>   
>>> Please do not make unnecessary kernel changes which require changes in 
>>> our systems.
>>>     
>
>>> If you think the e100 driver fixes your problems use it and be happy. But 
>>> since you don't have to test system behavior with the new driver, and you 
>>> won't be called at night or on weekends if it doesn't work, do the rest 
>>> of the world a favor and stop taking out things we know to work! Leaving 
>>> in the eepro100 causes no work for you, and even if e100 works perfectly 
>>> it needs to be validated in any sane network. it still makes work.
>>>     
>>
>> The goal is to get e100 better, and removing eepro100 helps with reaching 
>> this goal.
>>
>>   
> That's *your* goal, it should not be a shock that users have a goal of 
> using their systems without having to reconfigure them every time there's a 
> kernel upgrade containing a security fix.

For how many years do you know that there's a new and actively 
maintained e100 driver for your hardware?

And if you don't follow a stable line like the 2.6.16 kernel or a 
distribution kernel it's simply a part of the current development model 
that some kernel parts change. If changing one driver results in a big 
problem in your setup you should reconsider your setup. And every new 
kernel except for -stable kernels will anyway require a revalidation, so 
changing the network driver as part of this shouldn't be a big issue.

>> Why didn't _you_ try the e100 driver when you validated your systems after 
>> you upgraded them to kernel 2.6, and if you did and it didn't work, where 
>> is your bug report?
>>   
> Is that a joke, or subtle irony? Do you generally validate drivers you 
> don't use just because your hardware might be able to support them? I don't 
> validate various accelerated video drivers on systems running mostly text 
> console, never check sound options on systems with an audio application, 
> etc. After I tried the e100 driver on the first few systems and found 
> issues (which may be resolved by now) I went back to eepro100 and used what 
> worked. And used the driver for any new systems in other installs.

And exactly this is the reason why the eepro100 driver has to be 
removed, and that this will result in a better hardware support for 
everyone in the long term.

> If there were any benefit to removing a working driver I would at least be 
> able to see it as a resources issue, but as far as I can see you just seem 
> to have a personal preference for the e100 driver and want to force others 
> to use it because you are so much better able to decide what users need 
> than the system administrators. That's one of the reasons people choose 
> open source, because they have a choice, and can use what's best for them.

I don't have a personal preference for the e100 driver (although it's 
working fine in my computer), but I have a preference for the benefits 
of having only one driver for a given hardware over having two drivers.

People like you use the eepro100 driver instead of reporting the bugs in 
the e100 driver you ran into.

This is exactly the problem with two different drivers having different 
hardware support, different features and different bugs we should avoid.

One driver supporting all hardware, having all features and all bug 
fixes is a huge benefit.

In your prevous email you were whining "And for a number of card for old 
buses like ISA, EISA, and VESA, the e100 has not worked." although 
eepro100 didn't support such cards.

Now you claim to speak for "the system administrators".

Please bring some technical points, preferably bug reports for problems 
with e100 that don't exist with eepro100.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

