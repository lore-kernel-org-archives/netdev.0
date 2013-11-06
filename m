From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 3/3] net: allow to leave the buffer fragmented
 in skb_cow_data()
Date: Wed, 6 Nov 2013 17:30:28 +0800
Message-ID: <20131106093028.GA18435@gondor.apana.org.au>
References: <cover.1381923854.git.mathias.krause@secunet.com>
 <14f30e8f5f8405c1ca73b6d3a554441c1736142d.1381923854.git.mathias.krause@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	netdev@vger.kernel.org
To: Mathias Krause <mathias.krause@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:40200 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756046Ab3KFJah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 04:30:37 -0500
Content-Disposition: inline
In-Reply-To: <14f30e8f5f8405c1ca73b6d3a554441c1736142d.1381923854.git.mathias.krause@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 05, 2013 at 02:54:11PM +0100, Mathias Krause wrote:
>
> -	/* If skb is cloned or its head is paged, reallocate
> -	 * head pulling out all the pages (pages are considered not writable
> -	 * at the moment even if they are anonymous).
> +	/* If skb is cloned reallocate head pulling out all the pages (pages are
> +	 * considered not writable at the moment even if they are anonymous).
>  	 */

Hang on, you haven't explained why it is OK to write to pages.
What if said page is owned by the virt host or some app?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
