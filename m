From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Get rid of NETIF_F_INTERNAL_STATS
Date: Wed, 11 Apr 2007 22:23:17 +1000
Message-ID: <20070411122317.GA21159@gondor.apana.org.au>
References: <20070411075602.GA17635@gondor.apana.org.au> <1176293751.14322.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3690 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752064AbXDKMXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 08:23:33 -0400
Content-Disposition: inline
In-Reply-To: <1176293751.14322.14.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 11, 2007 at 10:15:51PM +1000, Rusty Russell wrote:
> 
> Actually, I did this precisely because I really didn't want to start
> exposing bogus stats in /proc/net/dev.  An audit might clarify if this
> is an actual issue.

Fair enough.  Still returning zeros when get_stats isn't available
would seem safe enough.  I wasn't able to find any drivers which
didn't have get_stats.

> > This also fixes a potential crash in those get_stats callers that
> > don't check for a NULL return value (e.g., /proc/net/dev).
> 
> Hmm, I thought it did that in my original patch?

Sorry, I was looking at the wrong tree.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
