From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [ PATCH 2.6.17-rc6 1/1] udp.c: counting InDatagrams which are never delivered
Date: Mon, 12 Jun 2006 17:43:45 +1000
Message-ID: <20060612074345.GB1273@gondor.apana.org.au>
References: <20060611.212913.70218067.davem@davemloft.net> <E1FpfkX-0000EL-00@gondolin.me.apana.org.au> <20060611.234905.35014718.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gerrit@erg.abdn.ac.uk, netdev@vger.kernel.org, kaber@coreworks.de,
	jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1811 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751101AbWFLHoB
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 03:44:01 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060611.234905.35014718.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 11, 2006 at 11:49:05PM -0700, David Miller wrote:
> 
> Yeah.  Good point.  But how much protocol internals do we want to
> slide into the ->data_ready() callbacks of such layers?  That's ugly
> and something we should try to avoid.

I agree with the objective of minimising the exposure of internals.
However, in this particular instance we're already exposing much more
than a couple of UDP SNMP counters in the sunrpc code.  This makes
adjusting the counters there the most expedient course of action.

Longer term we probably want to restructure the code a bit so that
more if it moves to udp.c.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
