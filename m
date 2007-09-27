From: David Miller <davem@davemloft.net>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Thu, 27 Sep 2007 12:48:22 -0700 (PDT)
Message-ID: <20070927.124822.102138627.davem@davemloft.net>
References: <20070927073446.GA14643@gondor.apana.org.au>
	<1190896785.4290.18.camel@localhost>
	<20070927125801.GB16706@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55059
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753009AbXI0TsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 15:48:22 -0400
In-Reply-To: <20070927125801.GB16706@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 27 Sep 2007 20:58:01 +0800

> On Thu, Sep 27, 2007 at 08:39:45AM -0400, jamal wrote:
> >
> > You also need to p->tcf_qstats.drops++ for all packets that get shot.
> 
> I was rather hoping that my packets wouldn't get shot :)
> But yeah let's increment the drops counter for consistency.
> 
> [PKT_SCHED]: Add stateless NAT

Applied to net-2.6.24, thanks Herbert!
