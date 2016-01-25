From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipv4+ipv6: Make INET*_ESP select CRYPTO_ECHAINIV
Date: Mon, 25 Jan 2016 21:56:28 +0800
Message-ID: <20160125135628.GA8256@gondor.apana.org.au>
References: <20160125102659.GA6976@gondor.apana.org.au>
 <56A60DF4.30700@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Thomas Egerer <hakke_007@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:48704 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756724AbcAYN4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 08:56:33 -0500
Content-Disposition: inline
In-Reply-To: <56A60DF4.30700@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 25, 2016 at 12:58:44PM +0100, Thomas Egerer wrote:
> The ESP algorithms using CBC mode require echainiv. Hence INET*_ESP have
> to select CRYPTO_ECHAINIV in order to work properly. This solves the
> issues caused by a misconfiguration as described in [1].
> The original approach, patching crypto/Kconfig was turned down by
> Herbert Xu [2].
> 
> [1] https://lists.strongswan.org/pipermail/users/2015-December/009074.html
> [2] http://marc.info/?l=linux-crypto-vger&m=145224655809562&w=2
> 
> Signed-off-by: Thomas Egerer <hakke_007@gmx.de>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
