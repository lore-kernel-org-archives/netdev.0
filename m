From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [2.6 patch] the overdue eepro100 removal
Date: Thu, 05 Jul 2007 12:01:56 -0400
Message-ID: <468D15F4.6020106@tmr.com>
References: <20070701202139.GM10869@stusta.de> <46894BD5.9080609@tmr.com> <46897212.30104@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	saw@saw.sw.com.sg, Linus Torvalds <torvalds@linux-foundation.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tmr.com ([64.65.253.246]:34742 "EHLO gaimboi.tmr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756266AbXGILS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2007 07:18:56 -0400
In-Reply-To: <46897212.30104@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please do not make unnecessary kernel changes which require changes in 
our systems.

Kok, Auke wrote:
> Bill Davidsen wrote:
>> Adrian Bunk wrote:
>>> This patch contains the overdue removal of the eepro100 driver.
>>>
>>> Signed-off-by: Adrian Bunk <bunk@stusta.de>
>>>
>> The hardware supported by this driver is still in use, thanks. It's 
>> probably easier to leave the eepro100 driver in than find anyone who 
>> wants to investigate why the other driver (e100? from memory) doesn't 
>> work with some cards. As I recall this was suggested over a year ago 
>> and it was decided to leave it in, all of the reasons for doing so 
>> still seem valid. There really doesn't seem to be a benefit, it's not 
>> like people are working night and day to support new cards for this 
>> chip.
>>
>
> please see the thread "Re: [PATCH] fix e100 rx path on ARM (was 
> [PATCH] e100 rx: or s and el bits)" which is discussing a fix for this 
> issue and currently being worked.
>
> eepro100 will *still* be removed once e100 is fixed to support those 
> devices.
>
Frankly I think there are more of us running old cards on PC hardware 
than people running ARM! And for a number of card for old buses like 
ISA, EISA, and VESA, the e100 has not worked. These are old PCs 
converted to routers and firewalls, and for security should not be left 
without upgrades.
> Moreover, we now also have a fix for the e100 IPMI issues on some tyan 
> boards (patch coming this week!). That hopefully solves all e100 
> issues that are still open.
>

If you think the e100 driver fixes your problems use it and be happy. 
But since you don't have to test system behavior with the new driver, 
and you won't be called at night or on weekends if it doesn't work, do 
the rest of the world a favor and stop taking out things we know to 
work! Leaving in the eepro100 causes no work for you, and even if e100 
works perfectly it needs to be validated in any sane network. it still 
makes work.

-- 
bill davidsen <davidsen@tmr.com>
  CTO TMR Associates, Inc
  Doing interesting things with small computers since 1979

