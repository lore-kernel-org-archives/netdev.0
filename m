From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [RFC][PATCH 8/9] 3c59x driver conversion
Date: Wed, 09 Aug 2006 09:03:21 +0200
Message-ID: <1155107002.23134.40.camel@lappy>
References: <20060808193447.1396.59301.sendpatchset@lappy>
	 <44D9191E.7080203@garzik.org>	<44D977D8.5070306@google.com>
	 <20060808.225537.112622421.davem@davemloft.net>
	 <44D980EB.5010608@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, phillips@google.com,
	netdev@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:10381 "EHLO
	amsfep20-int.chello.nl") by vger.kernel.org with ESMTP
	id S965093AbWHIHEI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 03:04:08 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44D980EB.5010608@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-09 at 02:30 -0400, Jeff Garzik wrote:
> David Miller wrote:
> > From: Daniel Phillips <phillips@google.com>
> > Date: Tue, 08 Aug 2006 22:51:20 -0700
> > 
> >> Elaborate please.  Do you think that all drivers should be updated to
> >> fix the broken blockdev semantics, making NETIF_F_MEMALLOC redundant?
> >> If so, I trust you will help audit for it?
> > 
> > I think he's saying that he doesn't think your code is yet a
> > reasonable way to solve the problem, and therefore doesn't belong
> > upstream.
> 
> Pretty much.  It is completely non-sensical to add NETIF_F_MEMALLOC, 
> when it should be blindingly obvious that every net driver will be 
> allocating memory, and every net driver could potentially be used with 
> NBD and similar situations.

Sure, but until every single driver is converted I'd like to warn people
about the fact that their setups is not up to expectations. Iff all
drivers are converted I'll be the forst to submit a patch that removes
the feature flag.

