From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/13]: net: Implement simple sw TX hashing.
Date: Mon, 14 Jul 2008 04:58:06 -0700 (PDT)
Message-ID: <20080714.045806.213105998.davem@davemloft.net>
References: <4877C76B.6010504@cosmosbay.com>
	<E1KIMIg-0007MB-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36394
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751911AbYGNL6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 07:58:06 -0400
In-Reply-To: <E1KIMIg-0007MB-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 14 Jul 2008 19:33:02 +0800

> Eric Dumazet <dada1@cosmosbay.com> wrote:
> >
> >> +     return hash % dev->real_num_tx_queues;
> > 
> > simple but expensive... but could be changed to use reciprocal_divide() if necessary...
> 
> For the common cases it should be a power of 2 too.

Unfortunately it is not enforcable for it to be a power of 2
and I fear it will in fact not be very often for several
chips that will use this stuff.

BTW, how can reciprocal_divide() be used to compute a modulus?  Are
you going to do the reciprocal divide, re-multiply, then subtract?
:-)

Sorry I haven't replied yet to all of this useful feedback, I'm still
killing myself to finish making the entire generic networking
multiqueue aware :(
