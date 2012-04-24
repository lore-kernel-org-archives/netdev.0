From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: usb: smsc95xx: fix mtu
Date: Tue, 24 Apr 2012 00:29:58 -0400 (EDT)
Message-ID: <20120424.002958.89736149140926804.davem@davemloft.net>
References: <20120420193923.GQ5277@charybde.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net
To: fillods@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751155Ab2DXEaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 00:30:11 -0400
In-Reply-To: <20120420193923.GQ5277@charybde.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephane Fillod <fillods@users.sf.net>
Date: Fri, 20 Apr 2012 21:39:23 +0200

> Make smsc95xx recalculate the hard_mtu after adjusting the
> hard_header_len.
> 
> Without this, usbnet adjusts the MTU down to 1488 bytes, and the host is
> unable to receive standard 1500-byte frames from the device.
> 
> Inspired by same fix on cdc_eem 78fb72f7936c01d5b426c03a691eca082b03f2b9.
> 
> Tested on ARM/Beagle.
> 
> Signed-off-by: Stephane Fillod <fillods@users.sf.net>

Applied, thanks.

Ok, now we've made this fix to 2 or 3 USB net drivers, can someone
audit to see if any more remain?
