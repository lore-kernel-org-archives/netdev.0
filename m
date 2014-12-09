From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 06/10] net/mlx4: Add mlx4_bitmap zone allocator
Date: Tue, 09 Dec 2014 14:42:10 -0500 (EST)
Message-ID: <20141209.144210.1356501987854068706.davem@davemloft.net>
References: <1417698835-11050-1-git-send-email-ogerlitz@mellanox.com>
	<1417698835-11050-7-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matanb@mellanox.com, amirv@mellanox.com,
	talal@mellanox.com, jackm@dev.mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37971 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752445AbaLITmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 14:42:12 -0500
In-Reply-To: <1417698835-11050-7-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu,  4 Dec 2014 15:13:51 +0200

> +static u32 mlx4_bitmap_max(struct mlx4_bitmap *bitmap)
> +{
> +	return bitmap->max;
> +}
> +
> +static u32 mlx4_bitmap_effective_len(struct mlx4_bitmap *bitmap)
> +{
> +	return bitmap->effective_len;
> +}

Using functions for just accessing structure members is excessive, please
just open code this.

Thanks.
