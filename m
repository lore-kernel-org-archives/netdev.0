From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8] netpoll: Allow netpoll_setup/cleanup recursion
Date: Thu, 24 Jun 2010 21:27:13 -0700 (PDT)
Message-ID: <20100624.212713.242141362.davem@davemloft.net>
References: <20100624182123.45264dfe.akpm@linux-foundation.org>
	<20100624.203006.35035648.davem@davemloft.net>
	<20100624205059.a28756b0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, mst@redhat.com, frzhang@redhat.com,
	netdev@vger.kernel.org, amwang@redhat.com, shemminger@vyatta.com,
	mpm@selenic.com, paulmck@linux.vnet.ibm.com,
	a.p.zijlstra@chello.nl, mingo@elte.hu
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49272
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750754Ab0FYE1B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 00:27:01 -0400
In-Reply-To: <20100624205059.a28756b0.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 24 Jun 2010 20:50:59 -0700

> What happens if you want to actually *drop* a patch from net-next? 
> Surely that happens?

I've only respun the tree on two or three occasions and that was
because I made some significant error myself and screwed up the
GIT tree somehow.

We've fixed much worse bugs than this one weeks after the changes
causing them went in, life goes on.

And the fact that it took two weeks of it being in -next before
anyone even reported it says how wide a net this particular bug
covers :-)  (hint: personally I've still never used netconsole
even one single time, and it's been around for what, something
like 6 years?)

