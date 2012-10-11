From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: Support devices reporting idleness
Date: Thu, 11 Oct 2012 15:20:23 -0400 (EDT)
Message-ID: <20121011.152023.1518627353741520073.davem@davemloft.net>
References: <1349959810-16607-1-git-send-email-oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oneukum@suse.de
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756163Ab2JKTU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 15:20:28 -0400
In-Reply-To: <1349959810-16607-1-git-send-email-oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>
Date: Thu, 11 Oct 2012 14:50:10 +0200

> Some device types support a form of power management in which
> the device suggests to the host that the device may be suspended
> now. Support for that is best located in usbnet.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>

Applied, but:

> +void usbnet_device_suggests_idle(struct usbnet *dev)
> +{
> +	if (!test_and_set_bit(EVENT_DEVICE_REPORT_IDLE, &dev->flags)) {
> +		dev->intf->needs_remote_wakeup = 1;
> +		usb_autopm_put_interface_async(dev->intf);
> +	}		
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trailing whitespace.
