From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net: fec: fix the warning found by dma
 debug
Date: Sat, 24 Jan 2015 21:54:06 -0800 (PST)
Message-ID: <20150124.215406.984030001159879061.davem@davemloft.net>
References: <1421734235-6563-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, festevam@gmail.com,
	christian.gmeiner@gmail.com, moon.linux@yahoo.com,
	bhutchings@solarflare.com, stephen@networkplumber.org
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60200 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbbAYFyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 00:54:09 -0500
In-Reply-To: <1421734235-6563-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Tue, 20 Jan 2015 14:10:35 +0800

> Enable kernel config "CONFIG_HAVE_DMA_API_DEBUG", FEC have kernel warning:
 ...
> There have one bug in .fec_enet_tx_queue() function to unmap the DMA memory:
> For SG or TSO, get one buffer descriptor and then unmap the related DMA memory, and then
> get the next buffer descriptor, loop to while() to check "TX_READY". If "TX_READY" bit
> still __IS__ existed in the BD (The next fraglist or next TSO packet is not transmited
> complitely), exit the current clean work. When the next work is triggered, it still repeat
> above step with the same BD. The potential issue is that unmap the same DMA memory for
> multiple times.
> 
> The patch fix the clean work for SG and TSO packet.
> 
> Reported-by: Anand Moon <moon.linux@yahoo.com>
> Reported-by: Christian Gmeiner <christian.gmeiner@gmail.com>
> Signed-off-by: Fugang Duan <B38611@freescale.com>

Applied.
