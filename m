From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xgmac: use bufsz not dma_buf_sz in rx_refill
Date: Thu, 29 Aug 2013 16:34:37 -0400 (EDT)
Message-ID: <20130829.163437.1817937756134021051.davem@davemloft.net>
References: <20130829201151.GJ8764@redacted.bos.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rob.herring@calxeda.com, netdev@vger.kernel.org
To: kyle@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38075 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754354Ab3H2Uej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 16:34:39 -0400
In-Reply-To: <20130829201151.GJ8764@redacted.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyle McMartin <kyle@redhat.com>
Date: Thu, 29 Aug 2013 16:11:51 -0400

> Noticed while debugging another issue that DMA debug turned up, looks
> like commit ef468d23 missed a case when switching to bufsz instead of
> priv->dma_buf_sz? (tbf, the whole handling of DMA buffers seems slightly
> suspect since we're not tracking the size, but trusting the hardware
> between map and unmap...)
> 
> Signed-off-by: Kyle McMartin <kyle@redhat.com>

Applied and queued up for -stable, thanks.
