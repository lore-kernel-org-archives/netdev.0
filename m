From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Fri, 8 Jun 2007 22:37:35 +1000
Message-ID: <20070608123735.GA24582@gondor.apana.org.au>
References: <1181253445.4071.4.camel@localhost> <20070607.154421.109060486.davem@davemloft.net> <1181256848.4071.57.camel@localhost> <20070607.160035.00774597.davem@davemloft.net> <1181262703.3688.10.camel@w-sridhar2.beaverton.ibm.com> <1181266536.4741.27.camel@localhost> <20070608103925.GA23598@gondor.apana.org.au> <1181302497.4063.37.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>, auke-jan.h.kok@intel.com,
	jeff@garzik.org, kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3946 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1763659AbXFHMiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 08:38:07 -0400
Content-Disposition: inline
In-Reply-To: <1181302497.4063.37.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 08, 2007 at 07:34:57AM -0400, jamal wrote:
> On Fri, 2007-08-06 at 20:39 +1000, Herbert Xu wrote:
> 
> > It would guard against the poll routine which would acquire this lock
> > when cleaning the TX ring.
> 
> Ok, then i suppose we can conclude it is a bug on e1000 (holds tx_lock
> on tx side and adapter queue lock on rx). Adding that lock will
> certainly bring down the performance numbers on a send/recv profile.
> The bizare thing is things run just fine even under the heavy tx/rx
> traffic i was testing under. I guess i didnt hit hard enough.

Hmm I wasn't describing how it works now.  I'm talking about how it
would work if we removed LLTX and replaced the private tx_lock with
netif_tx_lock.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
