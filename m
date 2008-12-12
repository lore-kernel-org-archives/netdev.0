From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 7/8] ethtool: Add GGRO and SGRO ops
Date: Sat, 13 Dec 2008 08:48:35 +1100
Message-ID: <20081212214835.GD11046@gondor.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0d2-0000rq-Dr@gondolin.me.apana.org.au> <1229112677.3051.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45178 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753441AbYLLVsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 16:48:40 -0500
Content-Disposition: inline
In-Reply-To: <1229112677.3051.9.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2008 at 08:11:17PM +0000, Ben Hutchings wrote:
> On Fri, 2008-12-12 at 16:31 +1100, Herbert Xu wrote:
> > ethtool: Add GGRO and SGRO ops
> > 
> > This patch adds the ethtool ops to enable and disable GRO.  It also
> > makes GRO depend on RX checksum offload much the same as how TSO
> > depends on SG support.
> [...]
> 
> Why don't you add NETIF_F_GRO to the flags handled by get_flags() and
> set_flags()?

Surely the patch itself has answered this :) It's because of the
dependency on RX checksum offload.  We want GRO to be off unless
RX checksum offload is on.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
