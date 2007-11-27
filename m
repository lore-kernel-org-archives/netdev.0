From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: DST_NOHASH flag and IPsec transformers routing tables - need some clarification
Date: Tue, 27 Nov 2007 09:57:05 +0800
Message-ID: <E1IwphB-0000Ff-00@gondolin.me.apana.org.au>
References: <d0383f90711260515p6155bd7bt196016fb4d8d4cdf@mail.gmail.com>
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: ianbrn@gmail.com (Ian Brown)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4559 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753146AbXK0B5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 20:57:09 -0500
In-Reply-To: <d0383f90711260515p6155bd7bt196016fb4d8d4cdf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ian Brown <ianbrn@gmail.com> wrote:
>
> NOHASH hints that we do not keep the
> an entry in a hash. I doubt that such dst_entries , which are created with
> IPsec and so has the DST_NOHASH flag set, are not kept in the routing cache?

Exactly, they're not in the routing cache (for IPv4 anyway,
there is no cache at all for IPv6).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
