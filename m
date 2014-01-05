From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_core: Warn if device doesn't have
 enough PCI bandwidth
Date: Sat, 04 Jan 2014 20:16:05 -0500 (EST)
Message-ID: <20140104.201605.1540682078247113302.davem@davemloft.net>
References: <1388863024-8718-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, eyalpe@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44651 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbaAEBQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 20:16:07 -0500
In-Reply-To: <1388863024-8718-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Sat,  4 Jan 2014 21:17:04 +0200

> +static int mlx4_get_pcie_dev_link_caps(struct mlx4_dev *dev,
 ...
> +	mlx4_check_pcie_caps(dev);

You don't care about the return value, make it return void.
