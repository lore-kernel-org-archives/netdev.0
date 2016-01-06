From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/12] net/mlx5_core: Introduce flow steering
 autogrouped flow table
Date: Tue, 05 Jan 2016 23:58:25 -0500 (EST)
Message-ID: <20160105.235825.203310986288483393.davem@davemloft.net>
References: <1452024253-21193-1-git-send-email-saeedm@mellanox.com>
	<1452024253-21193-2-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dledford@redhat.com, ogerlitz@mellanox.com,
	eranbe@mellanox.com, talal@mellanox.com, majd@mellanox.com,
	matanb@mellanox.com, maorg@mellanox.com, monis@mellanox.com,
	saeedm@dev.mellanox.co.il
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33626 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbcAFE6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 23:58:43 -0500
In-Reply-To: <1452024253-21193-2-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Tue,  5 Jan 2016 22:04:02 +0200

> -	/* Add node to tree */
> -	tree_init_node(&fg->node, 1, del_flow_group);

Why in the world would you take a properly formatted comment:

> +	/*Add node to tree*/

And proceed to molest it like this?

Please don't do this.
