From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sis900: print warning if MAC address is not available
Date: Sun, 03 Jan 2010 21:57:27 -0800 (PST)
Message-ID: <20100103.215727.177625500.davem@davemloft.net>
References: <20091230182243.GA26340@milesteg.arr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	erik.andren@gmail.com
To: venza@brownhat.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60550
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753195Ab0ADF5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 00:57:24 -0500
In-Reply-To: <20091230182243.GA26340@milesteg.arr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniele Venzano <venza@brownhat.org>
Date: Wed, 30 Dec 2009 19:22:43 +0100

> The attached patch prints a warning if the MAC address is all 0s in the
> sis900 driver.
> 
> The patch prints a warning whenever the MAC address read from the
> hardware is composed of all zeros.
> If the address cannot be read at all for some reason, the driver is
> already doing the right thing and bails out.
> In reference to bug 11649 from bugzilla.
> 
> Please test this patch, it is trivial, but I only test-compiled it since
> I no longer have the hardware.
> 
> Signed-off-by: Daniele Venzano <linux@brownhat.org>

We have a way to check for a valid mac address: is_valid_ether_addr()

Please use it instead of your home-grown function.
