From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [patch 2/3] hci_usb: remove code obfuscation
Date: Sat, 19 Apr 2008 03:28:34 +0200
Message-ID: <6A7ADC8A-E229-4EC6-9C75-00359946037F@holtmann.org>
References: <200804182046.m3IKks86014628@imap1.linux-foundation.org> <9BEB490E-DE8A-4018-9696-E5074CC638AC@holtmann.org> <20080418223430.GA13847@elf.ucw.cz>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, hidave.darkstar@gmail.com,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:34700 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224AbYDSB2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 21:28:38 -0400
In-Reply-To: <20080418223430.GA13847@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pavel,

>>> _urb_free is an alias for kfree... making code longer & harder to
>>> read. Remove it.
>>
>> our own URB handling here is broken anyway. It was a bad idea when  
>> we did
>> it, but at that time the USB susbsystem was not in that good shape  
>> that it
>> is today. So I would say leave this code as it is and concentrate  
>> on the
>> new btusb driver, but if it helps anybody I am happy to ACK this one.
>
> It currently corrupts memory (use after free) during suspend, and I'm
> trying to get that fixed. It is 90% reproducible.

that is good, because I can't reproduce it with any of my system.  
Don't ask me why. I really simply works. So if you figure it out, it  
would be great.

> It could be easily fixed by just not freeing the urbs during
> disconnect (introducing very very slow memory leak). Would that be
> acceptable?

I don't think so.

Have you ever tried btusb driver? That code is a lot cleaner and it  
uses USB anchors for the queued URBs (no home grown broken URB queues).

Regards

Marcel

