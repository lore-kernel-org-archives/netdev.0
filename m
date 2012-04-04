From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1 2/2] net/bonding: correctly proxy slave neigh
 param setup ndo function
Date: Wed, 04 Apr 2012 18:12:13 -0400 (EDT)
Message-ID: <20120404.181213.2086357060828338921.davem@davemloft.net>
References: <1333529780-28421-1-git-send-email-ogerlitz@mellanox.com>
	<1333529780-28421-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, netdev@vger.kernel.org, fubar@us.ibm.com,
	shlomop@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757172Ab2DDWMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 18:12:22 -0400
In-Reply-To: <1333529780-28421-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed,  4 Apr 2012 11:56:20 +0300

> From: Shlomo Pongratz <shlomop@mellanox.com>
> 
> The current implemenation was buggy for slaves who use ndo_neigh_setup,
> since the networking stack invokes the bonding device ndo entry (from
> neigh_params_alloc) before any devices are enslaved, and the bonding
> driver can't further delegate the call at that point in time. As a
> result when bonding IPoIB devices, the neigh_cleanup hasn't been called.
> 
> Fix that by deferring the actual call into the slave ndo_neigh_setup
> from the time the bonding neigh_setup is called.
> 
> Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>

Applied.
