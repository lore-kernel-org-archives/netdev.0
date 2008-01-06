From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] [XFRM]: Kill some bloat
Date: Sat, 05 Jan 2008 23:16:58 -0800 (PST)
Message-ID: <20080105.231658.168081302.davem@davemloft.net>
References: <1199540349385-git-send-email-ilpo.jarvinen@helsinki.fi>
	<E1JBJOR-0000jO-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org, acme@redhat.com,
	paul.moore@hp.com, latten@us.ibm.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52177
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751796AbYAFHQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2008 02:16:58 -0500
In-Reply-To: <E1JBJOR-0000jO-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 06 Jan 2008 11:29:35 +1100

> We should never use inline except when it's on the fast path and this
> is definitely not a fast path.  If a function ends up being called
> just once the compiler will most likely inline it anyway, making the
> use of the keyword inline redundant.

Similarly I question just about any inline usage at all in *.c files
these days.

I even would discourage it's use for fast-path cases as well.
