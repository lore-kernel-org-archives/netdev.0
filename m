From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 17/32] net: packet split receive api
Date: Tue, 07 Oct 2008 14:23:23 -0700 (PDT)
Message-ID: <20081007.142323.97501781.davem@davemloft.net>
References: <20081002130504.927878499@chello.nl>
	<20081002131608.749239880@chello.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	dlezcano@fr.ibm.com, penberg@cs.helsinki.fi, neilb@suse.de
To: a.p.zijlstra@chello.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36547
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755287AbYJGVXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 17:23:47 -0400
In-Reply-To: <20081002131608.749239880@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 02 Oct 2008 15:05:21 +0200

> Add some packet-split receive hooks.
> 
> For one this allows to do NUMA node affine page allocs. Later on these hooks
> will be extended to do emergency reserve allocations for fragments.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

The individual driver changes get a bunch of rejects in the net-next-2.6
tree, and you also missed some drivers such as NIU that also should use
these new interfaces.

So what I did for now was add just the non-driver parts that add the
interfaces themselves.

Thanks!

