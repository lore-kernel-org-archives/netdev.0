From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net PATCH 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Sat, 2 Apr 2016 10:19:17 +0800
Message-ID: <20160402021917.GA19570@gondor.apana.org.au>
References: <20160402015709.GA19365@gondor.apana.org.au>
 <1459563333.6473.302.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aduyck@mirantis.com, tom@herbertland.com, jesse@kernel.org,
	alexander.duyck@gmail.com, edumazet@google.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:45554 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095AbcDBCTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 22:19:36 -0400
Content-Disposition: inline
In-Reply-To: <1459563333.6473.302.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 01, 2016 at 07:15:33PM -0700, Eric Dumazet wrote:
> On Sat, 2016-04-02 at 09:57 +0800, Herbert Xu wrote:
> > 
> > We could easily fix that by adding a feature bit to control this,
> > something like SKB_GSO_TCP_FIXEDID.
> 
> I understood the patch allowed to aggregate 4 segments having
> 
> ID=12   ID=40   ID=80  ID=1000

Right.  But I haven't seen any justification that we should aggregate
such packets at all.  The only valid case that I have seen is for
the case of unchanging IDs, no?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
