From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net v2] xfrm: Fix crash observed during device
 unregistration and decryption
Date: Thu, 24 Mar 2016 08:45:14 +0800
Message-ID: <20160324004514.GA3110@gondor.apana.org.au>
References: <001c01d1849b$1c7c98e0$5575caa0$@codeaurora.org>
 <1458739547.10868.37.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160323132947.GA29938@gondor.apana.org.au>
 <1458754165.10868.41.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
	'Steffen Klassert' <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, jeromes@codeaurora.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:50665 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbcCXAp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 20:45:27 -0400
Content-Disposition: inline
In-Reply-To: <1458754165.10868.41.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 10:29:25AM -0700, Eric Dumazet wrote:
>
> OK, but before calling netif_rx() are we properly testing dev->flags
> IFF_UP status ?
> 
> Otherwise, we still allow packets being queued after flush_backlog() had
> been called.

That's the first thing enqueue_to_backlog tests.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
