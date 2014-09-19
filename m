From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] mlx4: CQE/EQE stride support
Date: Fri, 19 Sep 2014 17:32:08 -0400 (EDT)
Message-ID: <20140919.173208.77064865716362179.davem@davemloft.net>
References: <1411030261-12145-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, idos@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59444 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757848AbaISVcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 17:32:10 -0400
In-Reply-To: <1411030261-12145-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 18 Sep 2014 11:50:58 +0300

> This series from Ido Shamay is intended for archs having 
> cache line larger then 64 bytes.
> 
> Since our CQE/EQEs are generally 64B in those systems, HW will write
> twice to the same cache line consecutively, causing pipe locks due to
> he hazard prevention mechanism. For elements in a cyclic buffer, writes
> are consecutive, so entries smaller than a cache line should be
> avoided, especially if they are written at a high rate.
> 
> Reduce consecutive writes to same cache line in CQs/EQs, by allowing the
> driver to increase the distance between entries so that each will reside
> in a different cache line.

Series applied, thanks.
