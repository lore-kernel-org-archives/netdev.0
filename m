From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 net-next] net: introduce gro_frag_list_enable sysctl
Date: Wed, 30 Oct 2013 12:42:12 +0800
Message-ID: <20131030044212.GA3364@gondor.apana.org.au>
References: <1383059555.5464.33.camel@edumazet-glaptop.roam.corp.google.com>
 <20131029.194446.2215574000648693370.davem@davemloft.net>
 <1383094428.4857.16.camel@edumazet-glaptop.roam.corp.google.com>
 <20131029.220253.1263087684709722001.davem@davemloft.net>
 <1383106012.4857.26.camel@edumazet-glaptop.roam.corp.google.com>
 <20131030040818.GB2755@gondor.apana.org.au>
 <1383106577.4857.30.camel@edumazet-glaptop.roam.corp.google.com>
 <20131030041959.GA3162@gondor.apana.org.au>
 <1383107681.4857.33.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, christoph.paasch@uclouvain.be,
	netdev@vger.kernel.org, hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:60310 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750702Ab3J3EmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 00:42:18 -0400
Content-Disposition: inline
In-Reply-To: <1383107681.4857.33.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 29, 2013 at 09:34:41PM -0700, Eric Dumazet wrote:
>
> What matters ?
> 
> GRO ?

What matters is that you should not treat the forwarding case
separately from the host case.

For virtualisation the host case looks exactly like the forwarding
case.

IOW, if having a 64KB packet matters for the host, then it matters
for forwarding as well.

> Before my patch, GRO packets were 17 MSS, and nobody complained packets
> were too small, so what are you saying exactly ?

I'm not criticsing your mega-GRO patch at all.  That one is great
and means that we'll get aggregated packets up to 64K.  What we need
to do is just to patch up the GSO code so that it can handle these
mega-packets properly.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
