From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 19/24] [IPSEC]: Merge most of the output path
Date: Thu, 8 Nov 2007 19:29:21 +0800
Message-ID: <20071108112921.GB16688@gondor.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au> <E1Ipla8-0001IO-00@gondolin.me.apana.org.au> <4732F1B1.204@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2635 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756490AbXKHL3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 06:29:31 -0500
Content-Disposition: inline
In-Reply-To: <4732F1B1.204@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 08, 2007 at 12:23:29PM +0100, Patrick McHardy wrote:
>
> We have a few places that go though the trouble of selecting the
> "correct" hook value for the address family, even though the numerical
> values are identical. How about we just get rid of the different
> naming and use NF_INET_... for both IPv4 and IPv6?

Nice work! Thanks Patrick.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
