From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Fix for IPsec leakage with SELinux enabled - V.02
Date: Wed, 4 Oct 2006 23:41:17 +1000
Message-ID: <20061004134117.GA12726@gondor.apana.org.au>
References: <20061002134200.GA20441@2ka.mipt.ru> <Pine.LNX.4.64.0610021004180.9739@d.namei> <Pine.LNX.4.64.0610021020390.9909@d.namei> <20061003.161807.18306641.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmorris@namei.org, johnpol@2ka.mipt.ru, netdev@vger.kernel.org,
	sds@tycho.nsa.gov, vyekkirala@TrustedCS.com, paul.moore@hp.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Kazunori Miyazawa <kazunori@miyazawa.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:530 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S1030424AbWJDNmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 09:42:20 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061003.161807.18306641.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 03, 2006 at 04:18:07PM -0700, David Miller wrote:
> 
> As I review this patch I realize there is a question of
> semantics and prioritization here.

Indeed.  Unfortunately I was doing other things at the time
sub-policies were introduced so I didn't pay attention to it.

After a quick look, it seems that the intention is to perform
some sort of recursive lookup (restricted to 2 levels only).

If that is the intention, perhaps we should try to come up
with a better mechansim because hard-coding a single level
of recursion for mobility is probably not the best solution
as this is just a special case of the general nested tunnel
problem.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
