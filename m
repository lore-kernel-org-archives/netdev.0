From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [patch 3/3] hci_usb.h: fix hard-to-trigger race
Date: Fri, 18 Apr 2008 23:10:12 +0200
Message-ID: <55DEC459-2D49-4366-88CC-21E9CA6783DC@holtmann.org>
References: <200804182046.m3IKksxT014631@imap1.linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: hidave.darkstar@gmail.com, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, pavel@ucw.cz, pavel@suse.cz
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36750 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763592AbYDRVKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 17:10:16 -0400
In-Reply-To: <200804182046.m3IKksxT014631@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

> From: Pavel Machek <pavel@ucw.cz>
>
> If someone tries to _urb_unlink while _urb_queue_head is running,  
> he'll see
> _urb->queue == NULL and fail to do any locking.  Prevent that from  
> happening
> by strategically placed barriers.

let me repeat this, the hci_usb driver is not worth fixing. Doing our  
own URB handling is a bad idea. The btusb driver should fix all of  
this. Only exception is that it is missing all the quirks, but that  
was me being lazy.

Regards

Marcel

