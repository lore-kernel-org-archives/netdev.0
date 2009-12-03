From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/02]usbnet & cdc-ether: Autosuspend for online devices
Date: Thu, 03 Dec 2009 13:19:30 -0800 (PST)
Message-ID: <20091203.131930.42454846.davem@davemloft.net>
References: <200912032210.55403.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35748
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752749AbZLCVTX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:19:23 -0500
In-Reply-To: <200912032210.55403.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>
Date: Thu, 3 Dec 2009 22:10:55 +0100

> commit 17b97d1c24a061843a8f707e80f23a7b0b7647df
> Author: Oliver Neukum <oliver@neukum.org>
> Date:   Thu Dec 3 22:08:12 2009 +0100
> 
>     usbnet & cdc-ether: Autosuspend for online devices
>     
>     Using remote wakeup and delayed transmission to allow
>     online device to go into usb autosuspend.
>     Minimal alternate support for devices that don't support
>     remote wakeup.
>     
>     Signed-off-by: Oliver Neukum <oliver@neukum.org>

Oliver, this patch still doesn't apply after patch #1 is
added.

davem@sunset:~/src/GIT/net-next-2.6$ git am --signoff bundle-735.mbox 
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
You have new mail in /var/mail/davem
