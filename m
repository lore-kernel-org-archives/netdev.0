From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv4 net-next-2.6 1/5] XFRM,IPv6: Remove xfrm_spi_hash()
	dependency on destination address
Date: Mon, 4 Oct 2010 16:33:06 +0800
Message-ID: <20101004083306.GA17939@gondor.apana.org.au>
References: <cover.1286139128.git.arno@natisbad.org> <5a0e320544e253cc903cfd3292600b6bec044a5f.1286139129.git.arno@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:59993 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753038Ab0JDIdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 04:33:22 -0400
Content-Disposition: inline
In-Reply-To: <5a0e320544e253cc903cfd3292600b6bec044a5f.1286139129.git.arno@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 04, 2010 at 08:25:07AM +0200, Arnaud Ebalard wrote:
>
> At the moment, Linux XFRM stack includes the address when computing
> the hash to perform state lookup by SPI. This patch changes XFRM
> state hash computation to prevent destination address to be
> used. This will later allow finding states for packets w/ mangled
> destination addresses.

I'm fine with doing this for inbound SAs.  However, I can't see
how we can do this for outbound SAs where the SPI is chosen by
the remote end.

Incidentally, it appears that our hash could do with some
strengthening.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
