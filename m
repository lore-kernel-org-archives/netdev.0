From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: DST_NOHASH flag and IPsec transformers routing tables - need some clarification
Date: Mon, 26 Nov 2007 10:51:28 +0800
Message-ID: <E1IwU4G-00062t-00@gondolin.me.apana.org.au>
References: <d0383f90711250636ha8a419emeab52c7107c1d480@mail.gmail.com>
Cc: netdev@vger.kernel.org
To: ianbrn@gmail.com (Ian Brown)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1381 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754358AbXKZCvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2007 21:51:32 -0500
In-Reply-To: <d0383f90711250636ha8a419emeab52c7107c1d480@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ian Brown <ianbrn@gmail.com> wrote:
>
> 3) in net/core/dst.c:
> struct dst_entry *dst_destroy(struct dst_entry * dst)
>        {
>        ...
>        ...     
>  int nohash = dst->flags & DST_NOHASH;
>        ...
>        ...     
> }

You were so close :)

This is where it's used.  Look harder.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
