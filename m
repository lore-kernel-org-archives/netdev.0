From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_core: Limit count field to 24 bits in
 qp_alloc_res
Date: Wed, 26 Nov 2014 12:05:18 -0500 (EST)
Message-ID: <20141126.120518.132374532785732093.davem@davemloft.net>
References: <1416909271-28840-1-git-send-email-ogerlitz@mellanox.com>
	<20141125.141620.1331667846639491375.davem@davemloft.net>
	<5475E19D.5000508@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matanb@mellanox.com, amirv@mellanox.com,
	jackm@dev.mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbaKZRFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 12:05:21 -0500
In-Reply-To: <5475E19D.5000508@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 26 Nov 2014 16:20:13 +0200

> Currently, the upstream PF driver is wrongly NOT masking out these
> eight bits and as such, some VF drivers which are already setting
> them for optimized allocation are failing to allocate QPs as the
> count seen by the PF becomes way too large.  The optimization is
> best effort anyway, and hence we can safely ignore their request.

Ok, thanks for explaining.

Applied and queued up for -stable, thanks.
