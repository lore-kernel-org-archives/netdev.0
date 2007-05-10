From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sched: Optimize return value of qdisc_restart
Date: Thu, 10 May 2007 14:11:36 -0700 (PDT)
Message-ID: <20070510.141136.05775017.davem@davemloft.net>
References: <20070510115039.GA24439@gondor.apana.org.au>
	<20070510.045534.90119358.davem@davemloft.net>
	<20070510121010.GA25264@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, hadi@cyberus.ca, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58988
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755011AbXEJVLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 17:11:33 -0400
In-Reply-To: <20070510121010.GA25264@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 10 May 2007 22:10:10 +1000

> On Thu, May 10, 2007 at 04:55:34AM -0700, David Miller wrote:
> >
> > > [NET_SCHED]: Rationalise return value of qdisc_restart
> > 
> > Fair enough, patch applied :-)
> 
> Sorry, reading Thomas's patch made me realise that I've just added
> that bug all over again.
> 
> [NET_SCHED]: Reread dev->qdisc for NETDEV_TX_OK
> 
> Now that we return the queue length after NETDEV_TX_OK we better
> make sure that we have the right queue.  Otherwise we can cause a
> stall after a really quick dev_deactive/dev_activate.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

:-) Applied.
