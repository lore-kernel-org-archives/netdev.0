From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [patch 3/3] hci_usb.h: fix hard-to-trigger race
Date: Sat, 19 Apr 2008 03:25:01 +0200
Message-ID: <84989B1A-CC23-4E81-B2E2-06E5FA01612E@holtmann.org>
References: <200804182046.m3IKksxT014631@imap1.linux-foundation.org> <55DEC459-2D49-4366-88CC-21E9CA6783DC@holtmann.org> <20080418142153.4e0eb83b.akpm@linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: hidave.darkstar@gmail.com, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, pavel@ucw.cz, pavel@suse.cz
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:34692 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbYDSBZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 21:25:06 -0400
In-Reply-To: <20080418142153.4e0eb83b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

>>> If someone tries to _urb_unlink while _urb_queue_head is running,
>>> he'll see
>>> _urb->queue == NULL and fail to do any locking.  Prevent that from
>>> happening
>>> by strategically placed barriers.
>>
>> let me repeat this, the hci_usb driver is not worth fixing. Doing our
>> own URB handling is a bad idea. The btusb driver should fix all of
>> this. Only exception is that it is missing all the quirks, but that
>> was me being lazy.
>>
>
> ok...  But as long as the old code is buildable and installable, we  
> should
> fix bugs in it?

I am okay with it and happy to accept any fixes, but to be quite  
honest, that this driver still works is in some cases pure luck. Doing  
the URB handling by ourself is really simply plain work. No excuses  
here and parts of it is my fault. I know that. Hence I started a new  
implementation from scratch.

Regards

Marcel

