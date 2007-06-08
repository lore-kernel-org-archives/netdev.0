From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Fri, 8 Jun 2007 20:39:25 +1000
Message-ID: <20070608103925.GA23598@gondor.apana.org.au>
References: <1181253445.4071.4.camel@localhost> <20070607.154421.109060486.davem@davemloft.net> <1181256848.4071.57.camel@localhost> <20070607.160035.00774597.davem@davemloft.net> <1181262703.3688.10.camel@w-sridhar2.beaverton.ibm.com> <1181266536.4741.27.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>, auke-jan.h.kok@intel.com,
	jeff@garzik.org, kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3510 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933357AbXFHKkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2007 06:40:43 -0400
Content-Disposition: inline
In-Reply-To: <1181266536.4741.27.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 07, 2007 at 09:35:36PM -0400, jamal wrote:
> On Thu, 2007-07-06 at 17:31 -0700, Sridhar Samudrala wrote:
> 
> > If the QDISC_RUNNING flag guarantees that only one CPU can call
> > dev->hard_start_xmit(), then why do we need to hold netif_tx_lock
> > for non-LLTX drivers?
> 
> I havent stared at other drivers, but for e1000 seems to me 
> even if you got rid of LLTX that netif_tx_lock is unnecessary.
> Herbert?

It would guard against the poll routine which would acquire this lock
when cleaning the TX ring.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
