From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RPS and forwarding
Date: Mon, 26 Apr 2010 15:30:17 +0800
Message-ID: <20100426073017.GA22803@gondor.apana.org.au>
References: <z2w65634d661004252144z1bf72880wdf7a0143b8490ddf@mail.gmail.com> <20100426045316.GA21810@gondor.apana.org.au> <r2n65634d661004252200x4e7a49f1h181cdd69b3e4ebc0@mail.gmail.com> <20100425.232857.145290769.davem@davemloft.net> <20100426063136.GA22401@gondor.apana.org.au> <1272266716.2346.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:37698 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752774Ab0DZHa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 03:30:26 -0400
Content-Disposition: inline
In-Reply-To: <1272266716.2346.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 26, 2010 at 09:25:16AM +0200, Eric Dumazet wrote:
>
> RFS is already working like that, if RPS is not used in conjonction.
> 
> Forwarded traffic will see a non tagged rfs flow entry, so this skb will
> be processed by this cpu, not a remote one.
> 
> Currently, only an application can set a RFS flow entry.

I was referring to the case when a forwarded flow gets hashed to
the same index as a local flow.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
