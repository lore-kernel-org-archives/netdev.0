From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default
	configurable
Date: Wed, 1 Jul 2009 09:48:49 +0800
Message-ID: <20090701014849.GA29088@gondor.apana.org.au>
References: <1246379267.3749.42.camel@blaa> <20090630170027.GA22691@gondor.apana.org.au> <20090630.120608.193727499.davem@davemloft.net> <alpine.LSU.2.00.0906302211300.25417@fbirervta.pbzchgretzou.qr> <20090701062737.6cac2193.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Engelhardt <jengelh@medozas.de>,
	David Miller <davem@davemloft.net>, markmc@redhat.com,
	netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35474 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753516AbZGABs4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 21:48:56 -0400
Content-Disposition: inline
In-Reply-To: <20090701062737.6cac2193.lk-netdev@lk-netdev.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 01, 2009 at 06:27:37AM +0930, Mark Smith wrote:
>
> I'm not sure if it supposed to work on IP traffic carried within
> bridge PPPoE/PPP, but it does - and that was very, very confusing to
> work out what had happened too. PPPoE comes up, as does PPP and IPCP,
> but forwarded IP packets are dropped unless there is a FORWARD
> iptables rule.

At least this bit should be off by default now, along as VLAN
decoding which was a gaping hole.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
