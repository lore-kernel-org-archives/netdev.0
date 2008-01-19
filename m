From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6.25] [XFRM] Remove unneeded export of xfrm_output_resume() and remove its declaration from net/xfrm.h.
Date: Sun, 20 Jan 2008 07:32:44 +1100
Message-ID: <E1JGKMu-0008Tj-00@gondolin.me.apana.org.au>
References: <eb3ff54b0801190513k6b59ce6cq956ac8ebb6dc5e40@mail.gmail.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: ramirose@gmail.com (Rami Rosen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42355 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751283AbYASUcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2008 15:32:52 -0500
In-Reply-To: <eb3ff54b0801190513k6b59ce6cq956ac8ebb6dc5e40@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rami Rosen <ramirose@gmail.com> wrote:
> 
> The method xfrm_output_resume() is used only in net/xfrm/xfrm_output.c.
> 
> This patch removes using unneeded EXPORT_SYMBOL_GPL to export it in
> net/xfrm/xfrm_output.c and also removes its declaration in net/xfrm.h.

This will be used ESP.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
