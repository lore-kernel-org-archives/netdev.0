From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net: mv643xx_eth: potential NULL dereference in probe()
Date: Thu, 14 Nov 2013 03:12:05 -0500 (EST)
Message-ID: <20131114.031205.1409875507350049283.davem@davemloft.net>
References: <20131113075247.GI25541@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com, jgunthorpe@obsidianresearch.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20131113075247.GI25541@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 13 Nov 2013 10:52:47 +0300

> We assume that "mp->phy" can be NULL a couple lines before the
> dereference.
> 
> Fixes: 1cce16d37d0f ('net: mv643xx_eth: Add missing phy_addr_set in DT mode')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
