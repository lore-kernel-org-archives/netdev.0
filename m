From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware
 restart.
Date: Mon, 22 Sep 2008 10:22:01 -0400
Message-ID: <48D7AA09.8090202@tmr.com>
References: <20080921182835.GA11473@2ka.mipt.ru> <20080921113513.16677c4e@infradead.org> <20080921190050.GA20484@2ka.mipt.ru> <1222024444.3023.53.camel@johannes.berg> <20080921193809.GA8735@2ka.mipt.ru> <20080921124332.67ddc13a@infradead.org> <20080921202057.GB25052@2ka.mipt.ru> <20080921132753.5689b564@infradead.org> <20080921205706.GA24545@2ka.mipt.ru> <20080921233819.32714483@lxorguk.ukuu.org.uk> <20080921234403.GA17946@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	ipw2100-devel@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753347AbYIVOWY@vger.kernel.org>
In-Reply-To: <20080921234403.GA17946@2ka.mipt.ru>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ipw2100-devel@lists.sourceforge.net
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Sun, Sep 21, 2008 at 11:38:19PM +0100, Alan Cox (alan@lxorguk.ukuu.org.uk) wrote:
>>>> still more complex than needed; a WARN_ON_ONCE() will be enough.
>>> That allows to dump whatever number of warnings you want. The more we
>>> have, the louder will be customers scream.
>> But if Intel don't care then you can scream all you like 8)
> 
> That's what happens :)
> 
>> A WARN_ON_ONCE is sufficient to capture an idea of how many people it is
>> effecting and maybe to figure out what the trigger is from their reports,
>> at that point there is some chance to get it fixed (especially if its
>> remotely triggerable ;))
> 
> Well, redhat, suse and ubuntu bugzillas happend to be not enough. Why do
> you believe a single warning at a new place will be? or couple of tens
> or whatever else? If it cares, it cares. If it does not...
> 
Has it occurred to you that YOU have a problem on YOUR maschine, and that your 
patch would kill wireless for all the people who have the hardware on working 
systems? My experience was somewhat like Denys' except I got no notice, I just 
found that after an update the wireless worked solidly, and continued to do so 
until that laptop because obsolete and slow, and went to live with one of the 
teens in my family.

> I attracted vendor's attention, vendor told me to fix it myself and to
> create a patch to fill an entry in another 'bugzilla', so that vendor
> could get results and probably decide to walk down from the cloud and
> fix it.
> 
It would be good to gather data rather than claim it doesn't work, because for 
some set of machines it certainly does.

> So, if they do not care, I do not care about their care. That's the
> deal. I will try to find a workaround, even if it is a real crap,
> fortunately other users will not strike this bug too frequently.
> 
My experience with laptops has been that you fiddle with power saving, and more, 
and more, until you find the tricks which make the laptop save power by 
disabling something you need, like network or display. At least that's been both 
my practice and observation, that not every machine responds well to every power 
saving trick.

Have you checked for a BIOS update for the machine? Tried disabling all power 
saving settings and seeing if that changes the problem? I would normally assume 
you have, but you seem convinced that the bug is in the firmware and you're 
going to get it fixed. It may be a firmware bug, but if something in your system 
is triggering it, and most people don't have the problem, you might investigate 
a solution other than beating on Intel.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot
