From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] sungem: fix napi regression with reset work
Date: Thu, 29 Nov 2007 21:57:55 +1100
Message-ID: <20071129105755.GF22537@gondor.apana.org.au>
References: <1196107328.8459.8.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2018 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750857AbXK2K6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 05:58:01 -0500
Content-Disposition: inline
In-Reply-To: <1196107328.8459.8.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 09:02:08PM +0100, Johannes Berg wrote:
> sungem's gem_reset_task() will unconditionally try to disable NAPI even
> when it's called while the interface is not operating and hence the NAPI
> struct isn't enabled. Make napi_disable() depend on gp->running.
> 
> Also removes a superfluous test of gp->running in the same function.
> 
> Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

Patch applied to net-2.6.  Thanks Johannes!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
