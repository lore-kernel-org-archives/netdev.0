From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next 2/3 v2] bnx2: Add prefetches to rx path.
Date: Thu, 06 May 2010 22:18:04 -0700 (PDT)
Message-ID: <20100506.221804.67909927.davem@davemloft.net>
References: <1273172293-10241-1-git-send-email-mchan@broadcom.com>
	<1273172293-10241-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50179
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752449Ab0EGFR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 01:17:56 -0400
In-Reply-To: <1273172293-10241-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 6 May 2010 11:58:13 -0700

> Add prefetches of the skb and the next rx descriptor to speed up rx path.
> 
> Use prefetchw() for the skb [suggested by Eric Dumazet].
> 
> The rx descriptor is in skb->data which is mapped for streaming mode DMA.
> Eric Dumazet pointed out that we should not prefetch the data before
> dma_sync.  So we prefetch only if dma_sync is no_op on the system.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Also applied, thanks!
