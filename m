From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [2.6 patch] the overdue eepro100 removal
Date: Mon, 09 Jul 2007 10:37:29 -0700
Message-ID: <46927259.4060403@intel.com>
References: <20070701202139.GM10869@stusta.de> <46894BD5.9080609@tmr.com> <46897212.30104@intel.com> <468D15F4.6020106@tmr.com> <20070709125208.GZ3492@stusta.de> <4692701B.3030506@tmr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	saw@saw.sw.com.sg, Linus Torvalds <torvalds@linux-foundation.org>
To: Bill Davidsen <davidsen@tmr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:13482 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752852AbXGIRhc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2007 13:37:32 -0400
In-Reply-To: <4692701B.3030506@tmr.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bill Davidsen wrote:
> Adrian Bunk wrote:
>> On Thu, Jul 05, 2007 at 12:01:56PM -0400, Bill Davidsen wrote:
>>   
>>> Please do not make unnecessary kernel changes which require changes in our 
>>> systems.
> 
>>> If you think the e100 driver fixes your problems use it and be happy. But 
>>> since you don't have to test system behavior with the new driver, and you 
>>> won't be called at night or on weekends if it doesn't work, do the rest of 
>>> the world a favor and stop taking out things we know to work! Leaving in 
>>> the eepro100 causes no work for you, and even if e100 works perfectly it 
>>> needs to be validated in any sane network. it still makes work.
>>>     
>> The goal is to get e100 better, and removing eepro100 helps with 
>> reaching this goal.
>>   
> That's *your* goal, it should not be a shock that users have a goal of 
> using their systems without having to reconfigure them every time 
> there's a kernel upgrade containing a security fix.

unfortunately it is impossible for anyone to patch *every* old version of an OS 
there is. Not only do we not want to do this (too much work, little return), but 
most of the times it is exponentially more difficult to fix a security bug in an 
older OS version than a new one.

>> Why didn't _you_ try the e100 driver when you validated your systems 
>> after you upgraded them to kernel 2.6, and if you did and it didn't 
>> work, where is your bug report?
>>   
> Is that a joke, or subtle irony? Do you generally validate drivers you 
> don't use just because your hardware might be able to support them? I 
> don't validate various accelerated video drivers on systems running 
> mostly text console, never check sound options on systems with an audio 
> application, etc. After I tried the e100 driver on the first few systems 
> and found issues (which may be resolved by now) I went back to eepro100 
> and used what worked. And used the driver for any new systems in other 
> installs.
> 
> If there were any benefit to removing a working driver I would at least 
> be able to see it as a resources issue, but as far as I can see you just 
> seem to have a personal preference for the e100 driver and want to force 
> others to use it because you are so much better able to decide what 
> users need than the system administrators. That's one of the reasons 
> people choose open source, because they have a choice, and can use 
> what's best for them.

as discussed before we really want to avoid having (1) an unmaintained 
bitrotting driver for X and (2) one that should work because people are being 
paid to take care of it.

The community has always encouraged us to work with us fixing the last issues in 
e100 to make it work for everyone. After all, we have all the documentation and 
facilities here to do almost all of the work.

I asked Adrian to postpone removing the eepro100 driver since we know that e100 
is still not working on some platforms. However, if e100 is not working on your 
specific platform, then I would certainly like to know about your problem, and 
whether it still exists. This is orthogonal to your argument: Your complaint 
stands (and eepro100 will not be removed until we address the ARM platform 
issues), but I ask you kindly to work with us and test the current e100 driver 
and report any issues to us.

Cheers,

Auke
