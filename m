From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio_net: Fix IP alignment on non-mergeable RX path
Date: Thu, 11 Jun 2009 20:55:27 -0700 (PDT)
Message-ID: <20090611.205527.248808583.davem@davemloft.net>
References: <1244743266.9669.64.camel@w-sridhar.beaverton.ibm.com>
	<20090611205003.GA8677@gondor.apana.org.au>
	<200906120829.23999.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, sri@us.ibm.com, markmc@redhat.com,
	kudinskas@uk.ibm.com, aliguori@linux.vnet.ibm.com,
	pablo@uk.ibm.com, netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46596
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751972AbZFLDzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 23:55:25 -0400
In-Reply-To: <200906120829.23999.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Fri, 12 Jun 2009 08:29:22 +0930

> From: Herbert Xu <herbert@gondor.apana.org.au>
> 
> We need to enforce the IP alignment on the non-mergeable RX path just
> like the other RX path.  Not doing so results in misaligned IP
> headers.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Applied, thanks everyone.
