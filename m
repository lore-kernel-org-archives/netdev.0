From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netpoll + xmit_lock == deadlock
Date: Fri, 31 Jul 2009 09:27:53 +0800
Message-ID: <20090731012753.GA25895@gondor.apana.org.au>
References: <20090729073523.GA4515@gondor.apana.org.au> <1248894478.4545.2822.camel@calx> <20090729194300.GB17410@hmsreliant.think-freely.org> <1248904097.4545.2934.camel@calx> <20090729231517.GA32670@hmsreliant.think-freely.org> <20090729231735.GB14066@gondor.apana.org.au> <20090730010222.GA4169@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Matt Carlson <mcarlson@broadcom.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41598 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750745AbZGaB2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 21:28:10 -0400
Content-Disposition: inline
In-Reply-To: <20090730010222.GA4169@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2009 at 09:02:22PM -0400, Neil Horman wrote:
>
> Under what conditions do you try to take the xmit_lock from within a drivers
> ->poll routine?  Do you have an example?

tg3
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
