From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/niu: remove one superfluous dma mask check
Date: Thu, 03 May 2012 14:55:41 -0400 (EDT)
Message-ID: <20120503.145541.1415935370418437633.davem@davemloft.net>
References: <1336069320-23639-1-git-send-email-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bigeasy@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46425 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243Ab2ECS4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 14:56:48 -0400
In-Reply-To: <1336069320-23639-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Thu,  3 May 2012 20:22:00 +0200

> The idea here seems to be to get a 44bit DMA mask working and if this
> fails it should fallback to a 32bit DMA mask. The dma_mask variable is
> assigned once to 44bit and never updated. pci_set_dma_mask() and
> pci_set_consistent_dma_mask() are both implemented as functions so there
> is no evil macro which might update dma_mask. Looking at the assembly, I
> see a call to dma_set_mask() followed by dma_supported() and then a jump
> passed the second dma_set_mask(). The only way to get to second
> dma_set_mask() call is by an error code in the first one.
> 
> So I hereby remove the check since it looks superfluous. Please ignore
> the path if there is black magic involved.
> 
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

It looks like it's been this way since day one. :-)

Applied, thanks.
