From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [RFC 0/3] [IPSEC]: Add xfrm_mode support
Date: Sat, 6 May 2006 21:20:26 +1000
Message-ID: <20060506112026.GA27671@gondor.apana.org.au>
References: <1145343829.44448f556684c@webmail.hiit.fi> <20060418080340.GA2206@gondor.apana.org.au> <Pine.SOL.4.64.0604181512460.26361@kekkonen.cs.hut.fi> <20060419110209.GA15584@gondor.apana.org.au> <Pine.SOL.4.64.0604191529100.11141@kekkonen.cs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Diego Beltrami <Diego.Beltrami@hiit.fi>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:14094 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750774AbWEFLUk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 07:20:40 -0400
To: Miika Komu <miika@iki.fi>
Content-Disposition: inline
In-Reply-To: <Pine.SOL.4.64.0604191529100.11141@kekkonen.cs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

These patches abstract out the protocol-specific encapsulation parts of
IPsec into what I've termed xfrm_mode objects.  This allows us to share
a little bit more code.  But more importantly, it allows us to add new
encapsulation modes such as BEET or v4/v6 and v6/v4 without polluting
the generic xfrm_input/xfrm_output paths.

These patches are not yet ready to be applied as I need to test them
a bit more.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
