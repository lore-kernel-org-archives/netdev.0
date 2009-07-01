From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default
	configurable
Date: Wed, 1 Jul 2009 12:10:35 +0800
Message-ID: <20090701041034.GA29980@gondor.apana.org.au>
References: <1246379267.3749.42.camel@blaa> <20090630170027.GA22691@gondor.apana.org.au> <20090630.120608.193727499.davem@davemloft.net> <alpine.LSU.2.00.0906302211300.25417@fbirervta.pbzchgretzou.qr> <20090701011528.GA28676@gondor.apana.org.au> <alpine.LSU.2.00.0907010535170.6438@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, markmc@redhat.com,
	netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55829 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750856AbZGAEKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 00:10:40 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.0907010535170.6438@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 01, 2009 at 05:50:18AM +0200, Jan Engelhardt wrote:
> 
> On secondary thought, one could also argue that because conntrack 
> ignores the interface, two unrelated connections happening to be routed 
> through the same machine(*) are tracked as one, too.

Good point.  We really should make these risks much more explicit.

However, I still think the risk with bridging is higher, especially
in the presence of virtualisation.  Consider the scenario where you
have to VMs on the one host, each with a dedicated bridge with the
intention that neither should know anything about the other's
traffic.

With conntrack running as part of bridging, the traffic can now
cross over which is a serious security hole.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
