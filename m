From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 0/5] IPsec parallelization
Date: Mon, 01 Dec 2008 12:20:22 +0100
Message-ID: <87hc5o5eh5.fsf@basil.nowhere.org>
References: <20081201071614.GP476@secunet.com>
	<20081201084902.GA19904@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	klassert@mathematik.tu-chemnitz.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:55305 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751251AbYLALUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 06:20:15 -0500
In-Reply-To: <20081201084902.GA19904@gondor.apana.org.au> (Herbert Xu's message of "Mon, 1 Dec 2008 16:49:02 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> writes:
>
> I still think that you're much better off doing this in the
> crypto layer.  As it stands the only reason why this is attractive
> is because crypto is slow.
>
> Pretty soon processors will start providing crypto support natively
> so this will no longer be the case. 

I'm not sure that's a useful argument.  When cryptography is not
CPU bound anymore it will be memory bandwidth bound. And in this case
you can still get a win out of parallelization if you parallelize
over multiple sockets with own memory controller or own FSB
because that will give you more bandwidth.

-Andi

-- 
ak@linux.intel.com
