From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/4] [IPSEC]: Add xfrm_mode support
Date: Sat, 27 May 2006 21:32:36 +1000
Message-ID: <20060527113236.GA4203@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:12300 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750734AbWE0Lcm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 May 2006 07:32:42 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

These patches abstract out the protocol-specific encapsulation parts of
IPsec into what I've termed xfrm_mode objects.  This allows us to share
a little bit more code.  But more importantly, it allows us to add new
encapsulation modes such as BEET or v4/v6 and v6/v4 without polluting
the generic xfrm_input/xfrm_output paths.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
