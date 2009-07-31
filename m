From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netpoll + xmit_lock == deadlock
Date: Fri, 31 Jul 2009 09:30:17 +0800
Message-ID: <20090731013017.GB25895@gondor.apana.org.au>
References: <20090729073523.GA4515@gondor.apana.org.au> <1248894478.4545.2822.camel@calx> <20090729194300.GB17410@hmsreliant.think-freely.org> <20090729223831.GA14066@gondor.apana.org.au> <20090730010639.GB4169@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Matt Carlson <mcarlson@broadcom.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41605 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751143AbZGaBa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 21:30:26 -0400
Content-Disposition: inline
In-Reply-To: <20090730010639.GB4169@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2009 at 09:06:39PM -0400, Neil Horman wrote:
>
> but nothing in that path takes the xmit_lock.  The poll_lock is taken in that
> patch, but thats for recieve_side syncronization, not transmit side.  Nothing in
> the tg3 driver (to use your example), that I can see takes the xmit_lock in the
> rx path either, so I'm not really sure where you comming from here.

tg3_poll => tg3_poll_work => tg3_tx => netif_tx_lock
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
