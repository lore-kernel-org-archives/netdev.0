From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: cxgb3: Replace LRO with GRO
Date: Fri, 16 Jan 2009 10:58:03 +1100
Message-ID: <20090115235803.GA9000@gondor.apana.org.au>
References: <20090115211403.3792.24995.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50948 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756339AbZAOX6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 18:58:10 -0500
Content-Disposition: inline
In-Reply-To: <20090115211403.3792.24995.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Divy Le Ray <divy@chelsio.com> wrote:
> 
> Your patch looks fine. Early testing provides the same perfs
> seen with LRO.
> 
> I resubmit the original patch with 2 changes:
> - cxgb3_set_flags() removal did not apply.
>  commit 47fd23fe8efeea3af4593a8424419df48724eb25 had updated the routine.
> - replace the NETIF_F_LRO features flag with NETIF_F_GRO

Thanks for the update Divy! It looks good to me.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
