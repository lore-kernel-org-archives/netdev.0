From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net/mlx4: off by one in parse_trans_rule()
Date: Mon, 16 Jul 2012 22:58:48 -0700 (PDT)
Message-ID: <20120716.225848.2202032682404200150.davem@davemloft.net>
References: <20120711063336.GC11812@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadarh@mellanox.co.il, ogerlitz@mellanox.com,
	eugenia@mellanox.co.il, yevgenyp@mellanox.co.il,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46377 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419Ab2GQF6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 01:58:49 -0400
In-Reply-To: <20120711063336.GC11812@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 11 Jul 2012 09:33:36 +0300

> This should be ">=" here instead of ">".  MLX4_NET_TRANS_RULE_NUM is 6.
> We use "spec->id" as an array offset into the __rule_hw_sz[] and
> __sw_id_hw[] arrays which have 6 elements.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.

Dan, in the future please indicate clearly that your patches are
targetted at net-next specifically.  Thanks.
