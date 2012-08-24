From: David Miller <davem@davemloft.net>
Subject: Re: pull request: sfc-next 2012-08-24
Date: Fri, 24 Aug 2012 16:36:18 -0400 (EDT)
Message-ID: <20120824.163618.381563523721565027.davem@davemloft.net>
References: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56451 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922Ab2HXUgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 16:36:20 -0400
In-Reply-To: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 24 Aug 2012 20:46:14 +0100

> The following changes since commit 8f4cccbbd92f2ad0ddbbc498ef7cee2a1c3defe9:
> 
>   net: Set device operstate at registration time (2012-08-24 12:46:13 -0400)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem
> 
> (commit 8f8b3d518999fd1c342310910aa1e49112c86d05)
> 
> 1. Change the TX path to stop queues earlier and avoid returning
> NETDEV_TX_BUSY.
> 2. Remove some inefficiencies in soft-TSO.
> 3. Fix various bugs involving device state transitions and/or reset
> scheduling by error handlers.
> 4. Take advantage of my previous change to operstate initialisation.
> 5. Miscellaneous cleanup.

Looks good, pulled, thanks Ben.
