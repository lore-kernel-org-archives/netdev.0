From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Wed, 16 Dec 2009 15:38:07 +0200
Message-ID: <20091216133806.GB29522@redhat.com>
References: <20091213122512.GA17255@gondor.apana.org.au> <200912161311.40644.rusty@rustcorp.com.au> <20091216025331.GA13935@gondor.apana.org.au> <200912162315.38802.rusty@rustcorp.com.au> <20091216132217.GA29494@redhat.com> <20091216133512.GC18327@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41436 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933873AbZLPNlE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2009 08:41:04 -0500
Content-Disposition: inline
In-Reply-To: <20091216133512.GC18327@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 16, 2009 at 09:35:12PM +0800, Herbert Xu wrote:
> On Wed, Dec 16, 2009 at 03:22:18PM +0200, Michael S. Tsirkin wrote:
> >
> > Doesn't netif_stop_queue include an atomic op?
> > If yes, does not atomic imply wmb already?
> 
> Unfortunately it doesn't.

So do we need an rmb after testing it as well?
Lock would be simpler :)

> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
