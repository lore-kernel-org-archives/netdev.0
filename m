From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] the overdue eepro100 removal
Date: Mon, 9 Jul 2007 14:52:08 +0200
Message-ID: <20070709125208.GZ3492@stusta.de>
References: <20070701202139.GM10869@stusta.de> <46894BD5.9080609@tmr.com> <46897212.30104@intel.com> <468D15F4.6020106@tmr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	saw@saw.sw.com.sg, Linus Torvalds <torvalds@linux-foundation.org>
To: Bill Davidsen <davidsen@tmr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:55482 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751691AbXGIMvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 08:51:37 -0400
Content-Disposition: inline
In-Reply-To: <468D15F4.6020106@tmr.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 05, 2007 at 12:01:56PM -0400, Bill Davidsen wrote:
> Please do not make unnecessary kernel changes which require changes in our 
> systems.

Welcome to the kernel 2.6 development model.

> Kok, Auke wrote:
>> Bill Davidsen wrote:
>>> Adrian Bunk wrote:
>>>> This patch contains the overdue removal of the eepro100 driver.
>>>>
>>>> Signed-off-by: Adrian Bunk <bunk@stusta.de>
>>>>
>>> The hardware supported by this driver is still in use, thanks. It's 
>>> probably easier to leave the eepro100 driver in than find anyone who 
>>> wants to investigate why the other driver (e100? from memory) doesn't 
>>> work with some cards. As I recall this was suggested over a year ago and 
>>> it was decided to leave it in, all of the reasons for doing so still seem 
>>> valid. There really doesn't seem to be a benefit, it's not like people 
>>> are working night and day to support new cards for this chip.
>>>
>>
>> please see the thread "Re: [PATCH] fix e100 rx path on ARM (was [PATCH] 
>> e100 rx: or s and el bits)" which is discussing a fix for this issue and 
>> currently being worked.
>>
>> eepro100 will *still* be removed once e100 is fixed to support those 
>> devices.
>>
> Frankly I think there are more of us running old cards on PC hardware than 
> people running ARM! And for a number of card for old buses like ISA, EISA, 
> and VESA, the e100 has not worked. These are old PCs converted to routers 
> and firewalls, and for security should not be left without upgrades.

WTF are you talking about?

Both drivers only support PCI cards.

>> Moreover, we now also have a fix for the e100 IPMI issues on some tyan 
>> boards (patch coming this week!). That hopefully solves all e100 issues 
>> that are still open.
>
> If you think the e100 driver fixes your problems use it and be happy. But 
> since you don't have to test system behavior with the new driver, and you 
> won't be called at night or on weekends if it doesn't work, do the rest of 
> the world a favor and stop taking out things we know to work! Leaving in 
> the eepro100 causes no work for you, and even if e100 works perfectly it 
> needs to be validated in any sane network. it still makes work.

The goal is to get e100 better, and removing eepro100 helps with 
reaching this goal.

Why didn't _you_ try the e100 driver when you validated your systems 
after you upgraded them to kernel 2.6, and if you did and it didn't 
work, where is your bug report?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

