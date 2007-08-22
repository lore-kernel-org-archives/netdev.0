From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: net-2.6.24 failure with netconsole
Date: Wed, 22 Aug 2007 15:20:41 +0800
Message-ID: <E1INkW9-00004x-00@gondolin.me.apana.org.au>
References: <20070821225438.9493f44c.akpm@linux-foundation.org>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: akpm@linux-foundation.org (Andrew Morton)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2033 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757830AbXHVHUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 03:20:48 -0400
In-Reply-To: <20070821225438.9493f44c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> David, there's basically no reason ever why anyone should add BUG() or
> BUG_ON() to net code.  Please consider rejecting any patches which add new
> ones.  WARN_ON() is *much* better.  It at least gives the user a chance of
> getting some disgnostic info out, of performing additional tests or even of
> using their kernel if they want to test something else.  The only reason to
> choose BUG over WARN is if we're actually concerned about scrogging
> people's data, or serious things like that (ie: filesystems and mm).

Well, for networking if we continue after a serious coding
error it could result in a remote kernel compromise.  So
BUG_ON/BUG is not entirely useless.

I'm not claiming that it's necessarily the case here though :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
