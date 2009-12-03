From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] usbnet & cdc-ether: Autosuspend for online devices
Date: Thu, 03 Dec 2009 13:45:32 -0800 (PST)
Message-ID: <20091203.134532.225926933.davem@davemloft.net>
References: <200912032241.43772.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58028
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751028AbZLCVp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:45:26 -0500
In-Reply-To: <200912032241.43772.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>
Date: Thu, 3 Dec 2009 22:41:43 +0100

> From 17b97d1c24a061843a8f707e80f23a7b0b7647df Mon Sep 17 00:00:00 2001
> From: Oliver Neukum <oliver@neukum.org>
> Date: Thu, 3 Dec 2009 22:08:12 +0100
> Subject: [PATCH 2/2] usbnet & cdc-ether: Autosuspend for online devices
> 
> Using remote wakeup and delayed transmission to allow
> online device to go into usb autosuspend.
> Minimal alternate support for devices that don't support
> remote wakeup.
> 
> Signed-off-by: Oliver Neukum <oliver@neukum.org>

Same problem:

davem@sunset:~/src/GIT/net-next-2.6$ git am --signoff bundle-737.mbox
Applying: cdc-ether:Implement reset_resume()
Applying: usbnet & cdc-ether: Autosuspend for online devices
error: patch failed: drivers/net/usb/cdc_ether.c:411
error: drivers/net/usb/cdc_ether.c: patch does not apply
error: patch failed: drivers/net/usb/usbnet.c:353
error: drivers/net/usb/usbnet.c: patch does not apply
Patch failed at 0002 usbnet & cdc-ether: Autosuspend for online devices
When you have resolved this problem run "git am --resolved".
If you would prefer to skip this patch, instead run "git am --skip".
To restore the original branch and stop patching run "git am --abort".
davem@sunset:~/src/GIT/net-next-2.6$ 

But this all might be due to some other changes I applied today and
didn't push out yet to net-next-2.6, let me check on that for you.
