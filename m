From: David Miller <davem@davemloft.net>
Subject: Re: + oops-in-drivers-net-shaperc.patch added to -mm tree
Date: Fri, 26 Jan 2007 19:12:36 -0800 (PST)
Message-ID: <20070126.191236.41877838.davem@davemloft.net>
References: <20070125.193128.39155864.davem@davemloft.net>
	<E1HAbgn-00039h-00@gondolin.me.apana.org.au>
	<20070127010146.GA18851@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, deweerdt@free.fr,
	netdev@vger.kernel.org, frederik.deweerdt@gmail.com,
	shemminger@osdl.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45637
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752169AbXA0DMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 22:12:37 -0500
In-Reply-To: <20070127010146.GA18851@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 27 Jan 2007 12:01:46 +1100

> In fact, the shaper device doesn't even seem to take a ref count of
> the device it has attached to.  So that device can go away at any time.
> What's more, there are drivers that can change hard_header at run-time
> (s390).

Indeed, it needs to do refcounting or something here, at a minimum,
this driver is so buggy and full of problems :-/

Thankfully it's marked OBSOLETE so we'll get rid of it eventually :)
