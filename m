From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: sfc: Replace LRO with GRO
Date: Mon, 19 Jan 2009 14:40:06 +0000
Message-ID: <1232376006.3004.19.camel@achroite>
References: <20090113092625.GA28015@gondor.apana.org.au>
	 <20090115042422.GB29658@gondor.apana.org.au>
	 <20090118.215027.46669769.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:57399 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1749667AbZASOkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 09:40:14 -0500
In-Reply-To: <20090118.215027.46669769.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-01-18 at 21:50 -0800, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 15 Jan 2009 15:24:22 +1100
> 
> > sfc: Replace LRO with GRO
> > 
> > This patch makes sfc invoke the GRO hooks instead of LRO.  As
> > GRO has a compatible external interface to LRO this is a very
> > straightforward replacement.
> > 
> > Everything should appear identical to the user except that the
> > offload is now controlled by the GRO ethtool option instead of
> > LRO.  I've kept the lro module parameter as is since that's for
> > compatibility only.
> > 
> > I have eliminated efx_rx_mk_skb as the GRO layer can take care
> > of all packets regardless of whether GRO is enabled or not.
> > 
> > So the only case where we don't call GRO is if the packet checksum
> > is absent.  This is to keep the behaviour changes of the patch to
> > a minimum.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Applied for 2.6.30

Please could you push this and other GRO changes for .30 to
net-next-2.6?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

