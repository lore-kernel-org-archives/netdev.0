From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [patch 2/3] hci_usb: remove code obfuscation
Date: Fri, 18 Apr 2008 23:07:10 +0200
Message-ID: <9BEB490E-DE8A-4018-9696-E5074CC638AC@holtmann.org>
References: <200804182046.m3IKks86014628@imap1.linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: hidave.darkstar@gmail.com, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, pavel@ucw.cz, pavel@suse.cz
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:45606 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762929AbYDRVHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 17:07:15 -0400
In-Reply-To: <200804182046.m3IKks86014628@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

> From: Pavel Machek <pavel@ucw.cz>
>
> _urb_free is an alias for kfree... making code longer & harder to
> read. Remove it.

our own URB handling here is broken anyway. It was a bad idea when we  
did it, but at that time the USB susbsystem was not in that good shape  
that it is today. So I would say leave this code as it is and  
concentrate on the new btusb driver, but if it helps anybody I am  
happy to ACK this one.

Regards

Marcel

