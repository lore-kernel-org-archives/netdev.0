From: David Miller <davem@davemloft.net>
Subject: Re: [0/4] [IPSEC]: Add xfrm_mode support
Date: Sat, 27 May 2006 23:03:30 -0700 (PDT)
Message-ID: <20060527.230330.108807815.davem@davemloft.net>
References: <20060527113236.GA4203@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11489
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751726AbWE1GDQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 May 2006 02:03:16 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060527113236.GA4203@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 27 May 2006 21:32:36 +1000

> These patches abstract out the protocol-specific encapsulation parts of
> IPsec into what I've termed xfrm_mode objects.  This allows us to share
> a little bit more code.  But more importantly, it allows us to add new
> encapsulation modes such as BEET or v4/v6 and v6/v4 without polluting
> the generic xfrm_input/xfrm_output paths.

This is the second time I've reviewed this so I already know
it's good stuff :-)

I'll toss this into net-2.6.18, thanks a lot!
