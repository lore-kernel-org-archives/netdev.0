From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH (resubmit)][BRIDGE] Properly dereference the br_should_route_hook
Date: Fri, 30 Nov 2007 13:31:17 +1100
Message-ID: <20071130023117.GA25692@gondor.apana.org.au>
References: <474C43F4.5080704@openvz.org> <20071129130420.GA8487@gondor.apana.org.au> <20071129143650.GD32449@linux.vnet.ibm.com> <20071129234900.GB23769@gondor.apana.org.au> <20071130012501.GJ9059@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@openvz.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	bridge@lists.osdl.org, devel@openvz.org, ego@in.ibm.com
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3441 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1763922AbXK3Cbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 21:31:33 -0500
Content-Disposition: inline
In-Reply-To: <20071130012501.GJ9059@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 29, 2007 at 05:25:01PM -0800, Paul E. McKenney wrote:
>
> You have in mind something like the following?
> 
> #define rcu_assign_pointer(p, v) \
> 	({ \
> 		if (!__builtin_constant_p(v) || \
> 		    ((v) != NULL)) \
> 			smp_wmb(); \
> 		(p) = (v); \
> 	})

Yes that's what I was thinking.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
