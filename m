From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [2.6 patch] the overdue eepro100 removal
Date: Mon, 09 Jul 2007 15:38:27 -0400
Message-ID: <46928EB3.9020506@tmr.com>
References: <20070701202139.GM10869@stusta.de> <46894BD5.9080609@tmr.com> <46897212.30104@intel.com> <468D15F4.6020106@tmr.com> <20070709125208.GZ3492@stusta.de> <4692701B.3030506@tmr.com> <20070709175251.GG3492@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	saw@saw.sw.com.sg, Linus Torvalds <torvalds@linux-foundation.org>
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pool-70-109-119-137.alb.east.verizon.net ([70.109.119.137]:50113
	"EHLO gaimboi.tmr.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752852AbXGIUS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 16:18:29 -0400
In-Reply-To: <20070709175251.GG3492@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> On Mon, Jul 09, 2007 at 01:27:55PM -0400, Bill Davidsen wrote:

> For how many years do you know that there's a new and actively 
> maintained e100 driver for your hardware?
> 
> And if you don't follow a stable line like the 2.6.16 kernel or a 
> distribution kernel it's simply a part of the current development model 
> that some kernel parts change. If changing one driver results in a big 
> problem in your setup you should reconsider your setup. And every new 
> kernel except for -stable kernels will anyway require a revalidation, so 
> changing the network driver as part of this shouldn't be a big issue.
> 
Nothing is a "big issue" if you can force someone else to do the work. 
And if you have no impact from a production outage if some new driver 
works for hours and then does something unexpected.

>>> Why didn't _you_ try the e100 driver when you validated your systems after 
>>> you upgraded them to kernel 2.6, and if you did and it didn't work, where 
>>> is your bug report?
>>>   
>> Is that a joke, or subtle irony? Do you generally validate drivers you 
>> don't use just because your hardware might be able to support them? I don't 
>> validate various accelerated video drivers on systems running mostly text 
>> console, never check sound options on systems with an audio application, 
>> etc. After I tried the e100 driver on the first few systems and found 
>> issues (which may be resolved by now) I went back to eepro100 and used what 
>> worked. And used the driver for any new systems in other installs.
> 
> And exactly this is the reason why the eepro100 driver has to be 
> removed, and that this will result in a better hardware support for 
> everyone in the long term.
> 

If this was a case of a kernel change requiring an effort to keep the 
driver I would not be suggesting someone take time to update the driver 
from threads to tasklets or fartlets or whatever the next ultimate irq 
handling happens to be. But when there's zero effort at the moment to 
retain the driver, I think it's change for the sake of change.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot
