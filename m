From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Sun, 15 Jun 2008 13:38:19 +1000
Message-ID: <20080615033819.GA25133@gondor.apana.org.au>
References: <20080430214845.GC14219@solarflare.com> <E1JrWFU-0001ue-00@gondolin.me.apana.org.au> <20080501110225.GG14219@solarflare.com> <20080501140625.GA9055@gondor.apana.org.au> <20080615005133.GA2835@solarflare.com> <20080615014657.GB2835@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kmansley@solarflare.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35911 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755605AbYFODi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 23:38:28 -0400
Content-Disposition: inline
In-Reply-To: <20080615014657.GB2835@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 15, 2008 at 02:46:58AM +0100, Ben Hutchings wrote:
>
> > Can we distinguish them by testing skb->ip_summed == CHECKSUM_PARTIAL?
> > That is a requirement for using hardware segmentation offload (see
> > netif_needs_gso()) but an skb resulting from LRO should have ip_summed
> > set to either CHECKSUM_UNNECESSARY or CHECKSUM_NONE.
> 
> Actually, it seems like there's a cleaner test: gso_size != 0 &&
> gso_type == 0 (if we really want GSO then the latter must be set).
> I'll have to try that out.

Yeah either way should work.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
