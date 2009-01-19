From: David Miller <davem@davemloft.net>
Subject: Re: sfc: Replace LRO with GRO
Date: Mon, 19 Jan 2009 13:29:29 -0800 (PST)
Message-ID: <20090119.132929.108799868.davem@davemloft.net>
References: <20090115042422.GB29658@gondor.apana.org.au>
	<20090118.215027.46669769.davem@davemloft.net>
	<1232376006.3004.19.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39890
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752684AbZASV31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 16:29:27 -0500
In-Reply-To: <1232376006.3004.19.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 19 Jan 2009 14:40:06 +0000

> On Sun, 2009-01-18 at 21:50 -0800, David Miller wrote:
> > From: Herbert Xu <herbert@gondor.apana.org.au>
> > Date: Thu, 15 Jan 2009 15:24:22 +1100
> > 
> > > sfc: Replace LRO with GRO
> > > 
> > > This patch makes sfc invoke the GRO hooks instead of LRO.  As
> > > GRO has a compatible external interface to LRO this is a very
> > > straightforward replacement.
> > > 
> > > Everything should appear identical to the user except that the
> > > offload is now controlled by the GRO ethtool option instead of
> > > LRO.  I've kept the lro module parameter as is since that's for
> > > compatibility only.
> > > 
> > > I have eliminated efx_rx_mk_skb as the GRO layer can take care
> > > of all packets regardless of whether GRO is enabled or not.
> > > 
> > > So the only case where we don't call GRO is if the packet checksum
> > > is absent.  This is to keep the behaviour changes of the patch to
> > > a minimum.
> > > 
> > > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> > 
> > Applied for 2.6.30
> 
> Please could you push this and other GRO changes for .30 to
> net-next-2.6?

All of Herbert's bug fixes are going into net-2.6, and that's
where they will stay.

I haven't published my net-next-2.6 tree at all, because
Stephen Rothwell hasn't stated that such content is
OK yet for his -next tree.
