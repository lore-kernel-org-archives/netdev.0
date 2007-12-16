From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Sat, 15 Dec 2007 21:44:29 -0800 (PST)
Message-ID: <20071215.214429.121871076.davem@davemloft.net>
References: <20071215061021.GA26247@gondor.apana.org.au>
	<20071215024810.20b8a5ae.akpm@linux-foundation.org>
	<20071215131016.GA28705@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	ebiederm@xmission.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48754
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751758AbXLPFo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 00:44:29 -0500
In-Reply-To: <20071215131016.GA28705@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 15 Dec 2007 21:10:16 +0800

> On Sat, Dec 15, 2007 at 02:48:10AM -0800, Andrew Morton wrote:
> >
> > Now as a separate issue we (ie: you) need to work out what _other_ things
> > you want ASSERT_RTNL to check apart from "rtnl must be held".
> 
> Since we have now established that ASSERT_RTNL never actually
> warned about usage on paths with BH off, I think Eric's original
> patch is fine as it is and I owe him an apology.

Ok, same here...

Such situations (ASSERT_RTNL() in atomic context) have always
been bugs though, and that continues to be true and I think
the check should be added somehow.
