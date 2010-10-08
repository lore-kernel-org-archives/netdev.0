From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCHv4 net-next-2.6 1/5] XFRM,IPv6: Remove xfrm_spi_hash()
	dependency on destination address
Date: Fri, 8 Oct 2010 08:42:35 +0800
Message-ID: <20101008004235.GA25283@gondor.apana.org.au>
References: <cover.1286139128.git.arno@natisbad.org> <5a0e320544e253cc903cfd3292600b6bec044a5f.1286139129.git.arno@natisbad.org> <20101004083306.GA17939@gondor.apana.org.au> <8739sl8yw5.fsf@small.ssi.corp> <20101005021114.GA25681@gondor.apana.org.au> <20101005041707.GA26458@gondor.apana.org.au> <87fwwhoj73.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:50397 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754046Ab0JHAms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 20:42:48 -0400
Content-Disposition: inline
In-Reply-To: <87fwwhoj73.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 07, 2010 at 10:13:04PM +0200, Arnaud Ebalard wrote:
> 
> I think I will try the following alternative approach based on your
> comments and proposals:
> 
>  - drop my patch to change spi hash computation
>  - handle destination address remapping during input upon failure of
>    xfrm_state_lookup()
>  - handle source address remapping as it is currently done in the patch,
>    i.e. by comparing received one against x->props.saddr once the
>    state found and do 

I'm fine with this from IPsec's point-of-view.

On the other hand, if it is at all possible to setup these remapping
entries in the SADB beforehand, that would definitely be my
preferred solution.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
