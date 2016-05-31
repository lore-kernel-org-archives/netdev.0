From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/1] net: fec: update dirty_tx even if no skb
Date: Tue, 31 May 2016 11:58:28 -0700 (PDT)
Message-ID: <20160531.115828.1504167795656808366.davem@davemloft.net>
References: <1464381040-19896-1-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fugang.duan@nxp.com, lznuaa@gmail.com,
	fabio.estevam@nxp.com, l.stach@pengutronix.de, andrew@lunn.ch,
	tremyfr@gmail.com, gerg@uclinux.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de, holgerschurig@gmail.com
To: troy.kisky@boundarydevices.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36692 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755295AbcEaS63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 14:58:29 -0400
In-Reply-To: <1464381040-19896-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Troy Kisky <troy.kisky@boundarydevices.com>
Date: Fri, 27 May 2016 13:30:40 -0700

> If dirty_tx isn't updated, then dma_unmap_single
> can be called twice.
> 
> This fixes a
> [   58.420980] ------------[ cut here ]------------
> [   58.425667] WARNING: CPU: 0 PID: 377 at /home/schurig/d/mkarm/linux-4.5/lib/dma-debug.c:1096 check_unmap+0x9d0/0xab8()
> [   58.436405] fec 2188000.ethernet: DMA-API: device driver tries to free DMA memory it has not allocated [device address=0x0000000000000000] [size=66 bytes]
> 
> encountered by Holger
> 
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
> Tested-by: <holgerschurig@gmail.com>
> Acked-by: Fugang Duan <fugang.duan@nxp.com>

Applied.
