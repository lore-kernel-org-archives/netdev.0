From: David Miller <davem@davemloft.net>
Subject: Re: sfc: Replace LRO with GRO
Date: Sun, 18 Jan 2009 21:50:27 -0800 (PST)
Message-ID: <20090118.215027.46669769.davem@davemloft.net>
References: <20090113092625.GA28015@gondor.apana.org.au>
	<20090115042422.GB29658@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42579
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755513AbZASFuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 00:50:25 -0500
In-Reply-To: <20090115042422.GB29658@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 15 Jan 2009 15:24:22 +1100

> sfc: Replace LRO with GRO
> 
> This patch makes sfc invoke the GRO hooks instead of LRO.  As
> GRO has a compatible external interface to LRO this is a very
> straightforward replacement.
> 
> Everything should appear identical to the user except that the
> offload is now controlled by the GRO ethtool option instead of
> LRO.  I've kept the lro module parameter as is since that's for
> compatibility only.
> 
> I have eliminated efx_rx_mk_skb as the GRO layer can take care
> of all packets regardless of whether GRO is enabled or not.
> 
> So the only case where we don't call GRO is if the packet checksum
> is absent.  This is to keep the behaviour changes of the patch to
> a minimum.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied for 2.6.30
