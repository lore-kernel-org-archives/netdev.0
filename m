From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/1] net/macb: add TX multiqueue support for gem
Date: Fri, 12 Dec 2014 15:18:01 -0500 (EST)
Message-ID: <20141212.151801.1028504001305533230.davem@davemloft.net>
References: <cover.1418383702.git.cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, soren.brinkmann@xilinx.com,
	linux-kernel@vger.kernel.org
To: cyrille.pitchen@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38121 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756478AbaLLUSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 15:18:03 -0500
In-Reply-To: <cover.1418383702.git.cyrille.pitchen@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Date: Fri, 12 Dec 2014 13:26:43 +0100

> At the first look this patch may look quite big but it cannot be splitted.
> Each queue has its own dedicated IRQ, which should be handled.
> Also the Transmit Base Queue Pointer register of each available queue must be
> initialized before starting the transmission, otherwise the transmission will be
> halted immediately as HRESP errors are likely to occur.
> In addition, some fields had to be moved from struct macb into struct macb_queue
> so a common code could manage the queues.
> 
> This patch was applied to net-next and tested on a sama5d36ek board, which embeds
> both macb and gem IPs, to check the backward compatibility.
> 
> Also it was tested on a sama5dx FPGA platform with a gem designed to use 3 queues.
> Then we used the tc program to set a queue discipline policy as describe in the
> Documentation/networking/multiqueue.txt: we successfully used each queue.

Applied, thanks.
