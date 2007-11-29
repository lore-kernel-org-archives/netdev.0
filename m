From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp-illinois: incorrect beta usage
Date: Fri, 30 Nov 2007 01:12:55 +1100
Message-ID: <20071129141254.GC9145@gondor.apana.org.au>
References: <aa7d2c6d0711261023m3d2dd850o76a8f44aef022f39@mail.gmail.com> <001001c83063$9adbc9d0$d5897e82@csp.uiuc.edu> <20071128154725.29af2852@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julian Shao Liu <shaoliu@uiuc.edu>,
	"David S. Miller" <davem@davemloft.net>,
	'Lachlan Andrew' <lachlan.andrew@gmail.com>,
	shaoliu@Princeton.EDU, 'Douglas Leith' <doug.leith@nuim.ie>,
	'Robert Shorten' <robert.shorten@nuim.ie>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4385 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760658AbXK2OXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 09:23:37 -0500
Content-Disposition: inline
In-Reply-To: <20071128154725.29af2852@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 28, 2007 at 03:47:25PM -0800, Stephen Hemminger wrote:
> Lachlan Andrew observed that my TCP-Illinois implementation uses the
> beta value incorrectly:
>   The parameter  beta  in the paper specifies the amount to decrease
>   *by*:  that is, on loss,
>      W <-  W -  beta*W
>   but in   tcp_illinois_ssthresh() uses  beta  as the amount
>   to decrease  *to*: W <- beta*W
> 
> This bug makes the Linux TCP-Illinois get less-aggressive on uncongested network,
> hurting performance. Note: since the base beta value is .5, it has no
> impact on a congested network.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied to net-2.6.  Thanks Stephen!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
