From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default
	configurable
Date: Thu, 2 Jul 2009 00:33:35 +0800
Message-ID: <20090701163335.GA5559@gondor.apana.org.au>
References: <1246379267.3749.42.camel@blaa> <20090630170027.GA22691@gondor.apana.org.au> <4A4B24DE.10103@trash.net> <20090701090736.GA32306@gondor.apana.org.au> <4A4B2AA8.3090406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark McLoughlin <markmc@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59663 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753193AbZGAQdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 12:33:37 -0400
Content-Disposition: inline
In-Reply-To: <4A4B2AA8.3090406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 01, 2009 at 11:21:44AM +0200, Patrick McHardy wrote:
>
> Agreed, at least as long as this is still the default behaviour.
> Mark, could you add this to your patch? br_nf_pre_routing_finish()
> looks like a good place to print a warning when skb->nfct != NULL.

Here's a suggestion:

Can we add another field to the conntrack tuple? This would be used
to ensure that every bridge's conntrack is distinct from each other,
as well as that of the system IP stack.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
