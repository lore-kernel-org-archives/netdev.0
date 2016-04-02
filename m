From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net PATCH 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Sat, 2 Apr 2016 09:57:10 +0800
Message-ID: <20160402015709.GA19365@gondor.apana.org.au>
References: <1459536543.6473.289.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aduyck@mirantis.com, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:51200 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbcDBB50 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 21:57:26 -0400
Content-Disposition: inline
In-Reply-To: <1459536543.6473.289.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> I do not particularly care, but it is worth mentioning that GRO+TSO
> would not be idempotent anymore.

We could easily fix that by adding a feature bit to control this,
something like SKB_GSO_TCP_FIXEDID.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
