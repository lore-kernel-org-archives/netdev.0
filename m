From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] kfree(napi->skb) => kfree_skb
Date: Wed, 18 Mar 2009 23:16:05 -0700 (PDT)
Message-ID: <20090318.231605.246064232.davem@davemloft.net>
References: <49BF7DA1.6010805@gmail.com>
	<20090318.231043.56741082.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59548
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754109AbZCSGQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 02:16:18 -0400
In-Reply-To: <20090318.231043.56741082.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 18 Mar 2009 23:10:43 -0700 (PDT)

> From: Roel Kluin <roel.kluin@gmail.com>
> Date: Tue, 17 Mar 2009 11:38:25 +0100
> 
> > struct sk_buff pointers should be freed with kfree_skb.
> > 
> > Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> > ---
> > @@ -2669,11 +2669,11 @@ EXPORT_SYMBOL(netif_napi_add);
> >  void netif_napi_del(struct napi_struct *napi)
> >  {
> 
> Roel, what did you use to generate this patch? :-/
> 
> If you hand-edited the patch, please check your work before sending it
> out.

Don't bother resending Roel, I took care of it by hand.

Nobody is doing anything reasonably today, so I am just going
to start doing everything myself like I always seem to end
up doing :-/

Today sucks... so... much...

