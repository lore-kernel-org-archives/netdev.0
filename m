From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH ipsec-next] xfrm: use vmalloc_node() for percpu scratches
Date: Fri, 18 Oct 2013 20:46:59 +0800
Message-ID: <20131018124659.GA972@gondor.apana.org.au>
References: <20131017095502.GD7660@secunet.com>
 <20131017130740.D8741E8A5E@unicorn.suse.cz>
 <20131018092512.GA31491@secunet.com>
 <1382093656.3284.14.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:36464 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750962Ab3JRMrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 08:47:07 -0400
Content-Disposition: inline
In-Reply-To: <1382093656.3284.14.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 18, 2013 at 03:54:16AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> scratches are per cpu, we can use vmalloc_node() for proper
> NUMA affinity.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

I agree completely.

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
