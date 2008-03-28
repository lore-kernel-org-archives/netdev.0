From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Net: Don't send ICMP_FRAG_NEEDED for GSO packets
Date: Fri, 28 Mar 2008 16:24:12 -0700 (PDT)
Message-ID: <20080328.162412.50278632.davem@davemloft.net>
References: <200803281934.09308.rusty@rustcorp.com.au>
	<20080328084043.GA22513@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org, jheffner@psc.edu
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35516
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755950AbYC1XYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 19:24:17 -0400
In-Reply-To: <20080328084043.GA22513@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 28 Mar 2008 16:40:43 +0800

> On Fri, Mar 28, 2008 at 07:34:08PM +1100, Rusty Russell wrote:
> > Commit 9af3912ec9e30509b76cb376abb65a4d8af27df3 added a new check to
> > send ICMP fragmentation needed for large packets.
> > 
> > Unlike the check in ip_finish_output(), it doesn't check for GSO.  I
> > triggered this with the GSO TUN patches, so not sure if it needs to be
> > in 2.6.25 or not (do we otherwise forward GSO packets?).
> > 
> > Cc: John Heffner <jheffner@psc.edu>
> > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> Since this is a regression for Xen, I would say yes.

Applied.

But Rusty, when referencing commits, always provide a
text string of the commit's header line because in
different trees and backports the commit ID may
change.

I fixed it up this time...

Thanks.
