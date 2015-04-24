From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: CCM/GCM implementation defect
Date: Fri, 24 Apr 2015 13:35:14 +0800
Message-ID: <20150424053514.GA28717@gondor.apana.org.au>
References: <20150423032619.GA17648@gondor.apana.org.au>
 <20150423114533.GI8928@secunet.com>
 <1429795499.31437.9.camel@martin>
 <20150424053000.GA28657@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Paul Wouters <pwouters@redhat.com>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Martin Willi <martin@strongswan.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:39656 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754589AbbDXFfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 01:35:25 -0400
Content-Disposition: inline
In-Reply-To: <20150424053000.GA28657@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 24, 2015 at 01:30:00PM +0800, Herbert Xu wrote:
> Now we just need to figre out whether we're still OK with RFC4543.

Looks like we're OK here too as the diagram in section 3.5 says
that the IV should be included in the AAD.

So we're all good!

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
