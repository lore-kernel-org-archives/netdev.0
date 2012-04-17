From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: smsc75xx: fix mtu
Date: Mon, 16 Apr 2012 23:54:43 -0400 (EDT)
Message-ID: <20120416.235443.1617997001955260332.davem@davemloft.net>
References: <20120415213829.GI5277@charybde.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@smsc.com
To: fillods@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752586Ab2DQDyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 23:54:53 -0400
In-Reply-To: <20120415213829.GI5277@charybde.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephane Fillod <fillods@users.sf.net>
Date: Sun, 15 Apr 2012 23:38:29 +0200

> Make smsc75xx recalculate the hard_mtu after adjusting the
> hard_header_len.
> 
> Without this, usbnet adjusts the MTU down to 1492 bytes, and the host is
> unable to receive standard 1500-byte frames from the device.
> 
> Inspired by same fix on cdc_eem 78fb72f7936c01d5b426c03a691eca082b03f2b9.
> 
> Tested on ARM/Omap3 with EVB-LAN7500-LC.
> 
> Signed-off-by: Stephane Fillod <fillods@users.sf.net>

Applied, thanks.
