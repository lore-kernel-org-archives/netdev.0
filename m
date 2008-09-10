From: David Miller <davem@davemloft.net>
Subject: Re: xfrm_state locking regression...
Date: Tue, 09 Sep 2008 20:22:15 -0700 (PDT)
Message-ID: <20080909.202215.197131148.davem@davemloft.net>
References: <20080903055041.GA8547@gondor.apana.org.au>
	<20080909.200400.96645840.davem@davemloft.net>
	<20080910031559.GA27430@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60416
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751779AbYIJDWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 23:22:23 -0400
In-Reply-To: <20080910031559.GA27430@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 10 Sep 2008 13:15:59 +1000

> This patch is now redundant.

Ok.

> What could be done though is to remove x->all and restore the
> original walking by hashing.  This would eliminate a list node
> from xfrm_state, and would also restore the original dump ordering.

Yes I remember you mentioning that.

If you're too busy I can try to spin this idea into a patch.
