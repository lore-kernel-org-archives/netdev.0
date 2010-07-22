From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: macvtap: Limit packet queue length
Date: Fri, 23 Jul 2010 00:08:59 +0800
Message-ID: <20100722160859.GB30723@gondor.apana.org.au>
References: <20100722064157.GA25913@gondor.apana.org.au> <20100722074431.GA26744@gondor.apana.org.au> <201007221130.53612.arnd@arndb.de> <1279814726.3211.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Mark Wagner <mwagner@redhat.com>,
	Chris Wright <chrisw@sous-sol.org>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:35871 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754781Ab0GVQJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 12:09:05 -0400
Content-Disposition: inline
In-Reply-To: <1279814726.3211.5.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 22, 2010 at 09:05:26AM -0700, Shirley Ma wrote:
> On Thu, 2010-07-22 at 11:30 +0200, Arnd Bergmann wrote:
> > In the TX direction, we really don't queue, since we simply forward
> > to the lowerdev tx queue, so exposing the tunable to user space
> > as the tx queue length is a little bit awkward, as well as
> > inconsistent
> > between macvtap and macvlan.
> 
> Maybe we can use lowerdev backlog queue size here from receiving path
> here?

No, you may wish to set different queue lengths for different
macvtap devices over the same lowerdev so you definitely don't
want to use any lowerdev parameter for this.

I honestly don't see any problems with using tx_queue_len since
it isn't used by anything else for macvtap.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
