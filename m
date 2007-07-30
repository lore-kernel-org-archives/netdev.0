From: David Miller <davem@davemloft.net>
Subject: Re: [IPVS]: Use skb_forward_csum
Date: Mon, 30 Jul 2007 16:25:29 -0700 (PDT)
Message-ID: <20070730.162529.112287931.davem@davemloft.net>
References: <20070726085939.GA442@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, horms@verge.net.au
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34801
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757686AbXG3XZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 19:25:30 -0400
In-Reply-To: <20070726085939.GA442@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 26 Jul 2007 16:59:39 +0800

> [IPVS]: Use skb_forward_csum
> 
> As a path that forwards packets, IPVS should be using
> skb_forward_csum instead of directly setting ip_summed
> to CHECKSUM_NONE.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Patch applied, thanks Herbert.
