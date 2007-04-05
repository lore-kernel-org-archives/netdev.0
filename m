From: David Miller <davem@davemloft.net>
Subject: Re: [SC92031]: Fix priv->lock context
Date: Thu, 05 Apr 2007 09:59:29 -0700 (PDT)
Message-ID: <20070405.095929.79068467.davem@davemloft.net>
References: <20070404190402.609cbd65.akpm@linux-foundation.org>
	<20070405114431.GA10972@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, adaplas@pol.net,
	jgarzik@pobox.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38281
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753301AbXDEQ72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 12:59:28 -0400
In-Reply-To: <20070405114431.GA10972@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 5 Apr 2007 21:44:31 +1000

> On Thu, Apr 05, 2007 at 02:04:02AM +0000, Andrew Morton wrote:
> > 
> > This looks like a locking bug in the ipv6 changes in davem's devel tree.
> > There are no relevant changes to drivers/net/sc92031.c in rc5-mm4.
> 
> Actually, this looks like a latent bug in sc92031.  It's calling
> spin_lock in the dev->open function on a lock that's held in BH
> context.
> 
> [SC92031]: Fix priv->lock context

Where is the patch? :-)

Second time you've done this in two days Herbert, tsk tsk :)))
