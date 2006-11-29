From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lockdep: fix sk->sk_callback_lock locking
Date: Wed, 29 Nov 2006 12:06:07 -0800 (PST)
Message-ID: <20061129.120607.21923563.davem@davemloft.net>
References: <E1GpKC4-0005Vc-00@gondolin.me.apana.org.au>
	<1164800544.6588.118.camel@twins>
	<20061129120709.GB22749@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: a.p.zijlstra@chello.nl, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@osdl.org, mingo@elte.hu,
	gandalf@wlug.westbo.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:15260
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S936084AbWK2UGF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 15:06:05 -0500
To: herbert@gondor.apana.org.au
In-Reply-To: <20061129120709.GB22749@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 29 Nov 2006 23:07:09 +1100

> On Wed, Nov 29, 2006 at 12:42:24PM +0100, Peter Zijlstra wrote:
> > 
> > However I'm not quite sure yet how to teach lockdep about this. The
> > proposed patch will shut it up though.
> 
> As a rule I think we should never make semantic changes to shut up
> lockdep.

Especially ones which are costly, as this proposed change is in
that it disables software interrupts in a place where that
is completely unnecessary.

Let's not even consider this patch :)
