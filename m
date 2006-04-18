From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ip_route_input panic fix
Date: Tue, 18 Apr 2006 12:54:14 +1000
Message-ID: <20060418025414.GA32763@gondor.apana.org.au>
References: <20060417171253.4e988afc@localhost.localdomain> <E1FVfxQ-0008Tf-00@gondolin.me.apana.org.au> <20060417194931.032aba02@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from CyborgDefenseSystems.Corporatebeast.com ([64.62.148.172]:53260
	"EHLO arnor.apana.org.au") by vger.kernel.org with ESMTP
	id S1751382AbWDRCyT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 22:54:19 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060417194931.032aba02@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 17, 2006 at 07:49:31PM -0700, Stephen Hemminger wrote:
>
> Not really, just that ip_check_mc looks at the proto for !IGMP. And maybe
> some tool like coverity or sparse would be smart enough to look for
> uninitialized data usage.

That's a good point.

Thanks Stephen,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
