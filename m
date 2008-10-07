From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/32] net: ipv6: initialize ip6_route sysctl vars in
 ip6_route_net_init()
Date: Tue, 07 Oct 2008 14:15:45 -0700 (PDT)
Message-ID: <20081007.141545.92648748.davem@davemloft.net>
References: <20081002130504.927878499@chello.nl>
	<20081002131607.801664200@chello.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	dlezcano@fr.ibm.com, penberg@cs.helsinki.fi, neilb@suse.de
To: a.p.zijlstra@chello.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53863
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756048AbYJGVQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 17:16:10 -0400
In-Reply-To: <20081002131607.801664200@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Thu, 02 Oct 2008 15:05:08 +0200

> This makes that ip6_route_net_init() does all of the route init code.
> There used to be a race between ip6_route_net_init() and ip6_net_init()
> and someone relying on the combined result was left out cold.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Looks good, applied to net-next-2.6, thanks.
