From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] net: esp: check CRYPTO_TFM_REQ_DMA flag when
 allocating crypto request
Date: Fri, 13 Mar 2015 15:46:08 -0400 (EDT)
Message-ID: <20150313.154608.548532696978553073.davem@davemloft.net>
References: <1426266882-31626-1-git-send-email-horia.geanta@freescale.com>
	<1426266922-31679-1-git-send-email-horia.geanta@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, kim.phillips@freescale.com
To: horia.geanta@freescale.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1426266922-31679-1-git-send-email-horia.geanta@freescale.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Horia Geanta <horia.geanta@freescale.com>
Date: Fri, 13 Mar 2015 19:15:22 +0200

> Some crypto backends might require the requests' private contexts
> to be allocated in DMA-able memory.
> 
> Signed-off-by: Horia Geanta <horia.geanta@freescale.com>

No way.

Upper layers should be absolutely not required to know about such
requirements.

Such details _must_ be hidden inside of the crypto layer and drivers
and not leak out into the users of the crypto interfaces.
