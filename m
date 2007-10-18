From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: stateless 1:1 NAT
Date: Thu, 18 Oct 2007 08:45:52 +0800
Message-ID: <E1IiJWK-0007kz-00@gondolin.me.apana.org.au>
References: <4716510E.3090300@andrei.myip.org>
Cc: netdev@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2519 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1761393AbXJRAxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 20:53:10 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1IiJdL-0001pK-4F
	for <netdev@vger.kernel.org>; Thu, 18 Oct 2007 10:53:07 +1000
In-Reply-To: <4716510E.3090300@andrei.myip.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florin Andrei <florin@andrei.myip.org> wrote:
>
> Is it going to be possible to combine stateless 1:1 NAT with stateful 
> filtering?

It is but it's pointless unless you can somehow enumerate the
bad guys (or a superset of them) and redirect them to NOTRACK.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
