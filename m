From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mv643xx_eth: prevent interrupt storm on ifconfig down
Date: Mon, 19 Jan 2009 17:18:19 -0800 (PST)
Message-ID: <20090119.171819.17901719.davem@davemloft.net>
References: <20090119100921.GG17124@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tbm@cyrius.com, pacman@kosh.dhis.org, netdev@vger.kernel.org,
	matt@genesi-usa.com, paubert@iram.es
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45709
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759526AbZATBSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 20:18:17 -0500
In-Reply-To: <20090119100921.GG17124@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Mon, 19 Jan 2009 11:09:21 +0100

> From: Gabriel Paubert <paubert@iram.es>
> 
> Contrary to what the docs say, the 'extended interrupt cause' bit in
> the interrupt cause register (bit 1) appears to not be maskable on at
> least some of the mv643xx_eth platforms, making writing zeroes to the
> interrupt mask register but not the extended interrupt mask register
> insufficient to stop interrupts from occuring.  Therefore, also write
> zeroes to the extended interrupt mask register when shutting down the
> port.
> 
> This fixes the interrupt storm seen on the Pegasos board when shutting
> down the interface.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Also applied, thanks.
