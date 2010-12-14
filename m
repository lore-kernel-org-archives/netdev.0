From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] fragment locally-generated IPsec6 packets that need it
Date: Tue, 14 Dec 2010 09:09:29 +0800
Message-ID: <20101214010929.GA10354@gondor.apana.org.au>
References: <1292271571.8593.9.camel@w-dls.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:54420 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758701Ab0LNBJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 20:09:35 -0500
Content-Disposition: inline
In-Reply-To: <1292271571.8593.9.camel@w-dls.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 13, 2010 at 12:19:31PM -0800, David L Stevens wrote:
> This patch modifies IPsec6 to fragment IPv6 packets that are
> locally generated as needed.
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

Thanks for the patch!

> +EXPORT_SYMBOL_GPL(ip6_fragment);

There is no need to export this as xfrm6_output.c is always part
of ipv6.o.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
