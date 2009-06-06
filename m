From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: num_dma_maps is not used
Date: Fri, 05 Jun 2009 18:09:49 -0700 (PDT)
Message-ID: <20090605.180949.14879004.davem@davemloft.net>
References: <4A2925B7.6050800@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44494
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752668AbZFFBJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 21:09:48 -0400
In-Reply-To: <4A2925B7.6050800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 05 Jun 2009 16:03:35 +0200

> Get rid of num_dma_maps in struct skb_shared_info, as it seems unused.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

It's going to be used when architectures implement optimized
versions of skb_dma_map(), which can thus virtually map
page vectors via IOMMU's and thus the resulting number of
DMA address/length pairs will be smaller than (num_frags + 1)

Similarly to how dma_map_sg() works.
