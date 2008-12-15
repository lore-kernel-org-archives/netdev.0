From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 7/8] ethtool: Add GGRO and SGRO ops
Date: Mon, 15 Dec 2008 14:40:48 +1100
Message-ID: <20081215034048.GB28499@gondor.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0d2-0000rq-Dr@gondolin.me.apana.org.au> <1229112677.3051.9.camel@achroite> <20081212214835.GD11046@gondor.apana.org.au> <1229121327.3051.69.camel@achroite> <20081212224954.GA11636@gondor.apana.org.au> <Pine.WNT.4.64.0812141124040.13556@ppwaskie-MOBL2.amr.corp.intel.com> <20081214210916.GA26325@gondor.apana.org.au> <Pine.WNT.4.64.0812141351560.12712@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57292 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751884AbYLODky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2008 22:40:54 -0500
Content-Disposition: inline
In-Reply-To: <Pine.WNT.4.64.0812141351560.12712@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 14, 2008 at 02:00:18PM -0800, Waskiewicz Jr, Peter P wrote:
>
> > -static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso, int lro)
> > +static int dump_offload(int rx, int tx, int sg, int tso, int ufo, int gso,
> > +                       int gro, int lro)
> 
> Would it make better sense to add GRO after LRO?  I suppose it doesn't 
> make any difference, but I'm thinking of any possible way to provide ABI 
> compatibility.  I don't think it's possible though; just thinking out loud 
> here.

This is an internal iproute function, not part of any ABI :)

Longer term my plan is to first have LRO restricted to hardware
offload which cannot coexist with forwarding/bridging, and eventually
phased out completely.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
