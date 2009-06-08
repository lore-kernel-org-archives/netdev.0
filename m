From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: num_dma_maps is not used
Date: Mon, 08 Jun 2009 00:22:21 -0700 (PDT)
Message-ID: <20090608.002221.128580344.davem@davemloft.net>
References: <4A2925B7.6050800@gmail.com>
	<20090605.180949.14879004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60648
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751211AbZFHHWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 03:22:19 -0400
In-Reply-To: <20090605.180949.14879004.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 05 Jun 2009 18:09:49 -0700 (PDT)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 05 Jun 2009 16:03:35 +0200
> 
>> Get rid of num_dma_maps in struct skb_shared_info, as it seems unused.
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> It's going to be used when architectures implement optimized
> versions of skb_dma_map(), which can thus virtually map
> page vectors via IOMMU's and thus the resulting number of
> DMA address/length pairs will be smaller than (num_frags + 1)
> 
> Similarly to how dma_map_sg() works.

But we aren't doing that yet and I have no idea when I'll get
to it, so I've applied your patch for now, thanks!
