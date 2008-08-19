From: David Miller <davem@davemloft.net>
Subject: Re: Bluetooth fixes for 2.6.27
Date: Tue, 19 Aug 2008 01:38:25 -0700 (PDT)
Message-ID: <20080819.013825.262679245.davem@davemloft.net>
References: <1219134207.7591.112.camel@violet.holtmann.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50052
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753300AbYHSIiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 04:38:25 -0400
In-Reply-To: <1219134207.7591.112.camel@violet.holtmann.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Tue, 19 Aug 2008 10:23:27 +0200

> The removal of the /sys/class/bluetooth symlinks broke userspace
> assumption. This has been fixed now in a way we should have done it a
> long time ago.
> 
> For the btusb driver this adds the promised SCO support. The btusb
> driver is a new driver and will eventually replace hci_usb. Adding SCO
> support was the last missing piece. All distributions are using the
> hci_usb driver at the moment and you can only select one of them. So
> this can't introduce any regression. With this change the distributions
> are now able to select the new driver if they really want to.
> 
> I have one pending optimization for this driver, but that depends on the
> USB patches. The usb_unlink_anchored_urbs() is currently broken and thus
> we can't use it. I will submit this patch once the USB fixes got merged.
> 
> In addition, I finally cleaned out the MAINTAINERS file and the
> MODULE_AUTHOR tags to reflect maintainer information.

Pulled, thanks a lot Marcel.
