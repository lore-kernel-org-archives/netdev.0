From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/8] net/mlx5: Make the command interface
 cache more flexible
Date: Wed, 16 Nov 2016 13:55:11 -0500 (EST)
Message-ID: <20161116.135511.614933371173594632.davem@davemloft.net>
References: <1479245407-6884-1-git-send-email-saeedm@mellanox.com>
        <1479245407-6884-2-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mohamad@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47444 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932565AbcKPSzN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 13:55:13 -0500
In-Reply-To: <1479245407-6884-2-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Tue, 15 Nov 2016 23:30:00 +0200

> -struct cache_ent {
> +struct cmd_msg_cache {
>  	/* protect block chain allocations
>  	 */
>  	spinlock_t		lock;
>  	struct list_head	head;
> +	unsigned		max_inbox_size;
> +	unsigned		num_ent;

Always spell out fully the "unsigned int" type name instead of just
plain "unsigned".
