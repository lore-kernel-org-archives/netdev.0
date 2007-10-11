From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: authenc compile warnings in current net-2.6.24
Date: Thu, 11 Oct 2007 11:23:30 +0800
Message-ID: <20071011032330.GA14165@gondor.apana.org.au>
References: <470D11B1.2040207@hartkopp.net> <20071010195337.GA21597@Chamillionaire.breakpoint.cc> <20071010.162528.91758998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@ml.breakpoint.cc, socketcan@hartkopp.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4856 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756726AbXJKDYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 23:24:16 -0400
Content-Disposition: inline
In-Reply-To: <20071010.162528.91758998.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 10, 2007 at 04:25:28PM -0700, David Miller wrote:
>
> It's just not smart enough to see that cryptlen's initialization
> and it's use in the auth_unlock label path are both protected
> by 'err' being non-zero.
> 
> To be honest I don't know of any compiler which commits enough
> flow variable analysis to support doing %100 accurate warnings
> in situations like this.
> 
> Since the compiler is unlikely to do so, I think we should fix
> it somehow because useless warnings just distract.

Yeah I've added a fix in the cryptodev tree.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
