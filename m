From: David Miller <davem@davemloft.net>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Thu, 27 Sep 2007 12:52:39 -0700 (PDT)
Message-ID: <20070927.125239.129764503.davem@davemloft.net>
References: <20070927132037.GA17056@gondor.apana.org.au>
	<20070927132941.GB25353@2ka.mipt.ru>
	<46FBB296.8020901@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40729
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753188AbXI0Twk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 15:52:40 -0400
In-Reply-To: <46FBB296.8020901@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 27 Sep 2007 15:39:34 +0200

> Evgeniy Polyakov wrote:
> > On Thu, Sep 27, 2007 at 09:20:37PM +0800, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > 
> >>How about putting it in net/core/utils.c?
> > 
> > 
> > I knew, that was a bad idea to try to fix netfilter dependency :)
> > 
> > diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
> 
> 
> This looks good to me.

I still think the nf_*() prefixes should all go and the extern
prototypes should go into an independant header file.

These are not netfilter routines, they are "INET" helpers.

And we should make similar treatment for all of the ipv6
packet parser helper functions that ipv6 netfilter needs.
