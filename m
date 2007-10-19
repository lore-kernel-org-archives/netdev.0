From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Let inet_diag and friends autoload
Date: Fri, 19 Oct 2007 01:34:05 -0700 (PDT)
Message-ID: <20071019.013405.64830631.davem@davemloft.net>
References: <20071017.195125.15264659.davem@davemloft.net>
	<E1Iin6h-000367-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdelvare@suse.de, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59820
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933225AbXJSIdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 04:33:52 -0400
In-Reply-To: <E1Iin6h-000367-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 19 Oct 2007 16:21:23 +0800

> David Miller <davem@davemloft.net> wrote:
> >
> > I'm concerned it might be dangerous to load the module in
> > this context, the RTNL semaphore is held and the module we
> > are requesting could easily try to take it and deadlock.
> 
> We shouldn't be holding the RTNL here.  AFAICS we only hold
> inet_diag_mutex which is used in just one spot.

You're right.

I'll reconsider these patches.
