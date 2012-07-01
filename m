From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 03/10] net/mlx4_en: Re-design multicast
 attachments flow
Date: Sun, 01 Jul 2012 03:32:00 -0700 (PDT)
Message-ID: <20120701.033200.1718108360478891914.davem@davemloft.net>
References: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>
	<1341135823-29039-4-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, yevgenyp@mellanox.com, oren@mellanox.com,
	netdev@vger.kernel.org, yevgenyp@mellanox.co.il,
	sbohrer@rgmadvisors.com, hadarh@mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47627 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069Ab2GAKcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 06:32:01 -0400
In-Reply-To: <1341135823-29039-4-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  1 Jul 2012 12:43:36 +0300

> +	/* Find all the entries that should be removed from dst,
> +	 * These are the entries that are not found in src */

Improperly formatted comment.

> +			new_mc = kmalloc(sizeof(struct mlx4_en_mc_list),
> +					     GFP_KERNEL);

Improperly indented second line.
