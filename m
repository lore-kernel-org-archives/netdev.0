From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 15682] New: XFRM is not updating RTAX_ADVMSS
 metric
Date: Wed, 07 Apr 2010 16:47:23 -0700 (PDT)
Message-ID: <20100407.164723.85535751.davem@davemloft.net>
References: <20100405125055.cdc1e279.akpm@linux-foundation.org>
	<1270561240.7198.3.camel@bigi>
	<20100407135446.GA13394@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, eduardo.panisset@gmail.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55003
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756418Ab0DGXrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 19:47:20 -0400
In-Reply-To: <20100407135446.GA13394@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 7 Apr 2010 21:54:46 +0800

> Dave, what do you think about us starting to update ADVMSS on
> the fly, just like the MTU?

This sounds fine.

> The only risk is that existing users who are forcing ADVMSS to
> a value higher than what it would otherwise be would now get a
> lower value, if they're not using the "lock" keyword.
> 
> This shouldn't be fatal as it would only result in smaller packets
> which should still work, and they can always start using the
> "lock" keyword to get back the old behaviour.

And if we get them to fix their kit and use the lock setting,
it'll work in older kernels too.
