From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in RCU.
Date: Mon, 21 Jul 2008 19:36:00 +0800
Message-ID: <20080721113600.GA10322@gondor.apana.org.au>
References: <E1KKZmE-0000ty-00@gondolin.me.apana.org.au> <1216568119.4847.101.camel@localhost> <20080721001119.GA6515@gondor.apana.org.au> <1216607637.4847.172.camel@localhost> <20080721031716.GA7535@gondor.apana.org.au> <1216638879.4847.210.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36593 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752351AbYGULgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 07:36:11 -0400
Content-Disposition: inline
In-Reply-To: <1216638879.4847.210.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2008 at 07:14:39AM -0400, jamal wrote:
> 
> > Only if you also want to share it :) In the end I patched it to
> > not share it which is much easier.
> 
> I am trying to visualize: if you dont share, you must have 256K copies
> then? Assuming also you have a fast lookup since that was design intent.

They can't be shared anyway because each of those 256K rules NATs
to a different IP address.

> #ifdef CONFIG_HASH_SIZE
> #define NAT_TAB_MASK CONFIGURED_HASH_SIZE
> #else
> #define NAT_TAB_MASK 15
> #endif
> 
> What do you think?

Sorry, I think I'll have to poke my eyes out :)

But yeah if we ever get a generic dynamic hash table implmenetation
then I'd be happy for act_nat to use that.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
