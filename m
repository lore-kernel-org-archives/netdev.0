From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Thu, 1 May 2008 20:19:45 +0800
Message-ID: <20080501121945.GA8389@gondor.apana.org.au>
References: <20080430214845.GC14219@solarflare.com> <E1JrWFU-0001ue-00@gondolin.me.apana.org.au> <20080501110225.GG14219@solarflare.com> <1209640128.4191.30.camel@moonstone.uk.level5networks.com> <20080501111247.GA7756@gondor.apana.org.au> <1209640688.4191.35.camel@moonstone.uk.level5networks.com> <20080501113716.GA7955@gondor.apana.org.au> <20080501120850.GH14219@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kieran Mansley <kmansley@solarflare.com>, davem@davemloft.net,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48974 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752460AbYEAMTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 08:19:52 -0400
Content-Disposition: inline
In-Reply-To: <20080501120850.GH14219@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 01, 2008 at 01:08:51PM +0100, Ben Hutchings wrote:
>
> Depending on the driver, the packets may be received into skbs which are
> then attached to frag_list, or into page buffers which go in the frags
> array.  If most packets can be merged by LRO, deferring skb allocation
> and using the frags array is a performance win.

But for each packet it's either going to be frag_list or page
frags, right? So we could still fragment based on frag_list if
it's present.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
