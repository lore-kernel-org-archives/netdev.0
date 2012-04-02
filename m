From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: cdc_eem: fix mtu
Date: Sun, 01 Apr 2012 23:33:08 -0400 (EDT)
Message-ID: <20120401.233308.282185514386145568.davem@davemloft.net>
References: <1333041315-4303-1-git-send-email-rabin@rab.in>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.name, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: rabin@rab.in
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47208 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754091Ab2DBDdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 23:33:12 -0400
In-Reply-To: <1333041315-4303-1-git-send-email-rabin@rab.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rabin Vincent <rabin@rab.in>
Date: Thu, 29 Mar 2012 22:45:15 +0530

> Make CDC EEM recalculate the hard_mtu after adjusting the
> hard_header_len.
> 
> Without this, usbnet adjusts the MTU down to 1494 bytes, and the host is
> unable to receive standard 1500-byte frames from the device.
> 
> Tested with the Linux USB Ethernet gadget.
> 
> Cc: Oliver Neukum <oliver@neukum.name>
> Signed-off-by: Rabin Vincent <rabin@rab.in>

Applied and queued up for -stable, thanks.
