From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net/mlx4_en: Use affinity hint
Date: Wed, 01 Jan 2014 22:13:55 -0500 (EST)
Message-ID: <20140101.221355.18438692654233903.davem@davemloft.net>
References: <1388581537-4810-1-git-send-email-amirv@mellanox.com>
	<1388581537-4810-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, yuvala@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbaABDN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 22:13:56 -0500
In-Reply-To: <1388581537-4810-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Wed,  1 Jan 2014 15:05:36 +0200

> +						   &priv->rx_ring[cq_idx]
> +							->affinity_mask)){

Splitting up a pointer dereference like this looks aweful.

This code block is very deeply indented, which is what causes this
problem in the first place.  Abstract it out completely into a helper
function.
