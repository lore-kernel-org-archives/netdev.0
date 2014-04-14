From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1] net/mlx4_core: Defer VF initialization till PF
 is fully initialized
Date: Mon, 14 Apr 2014 13:25:04 -0400 (EDT)
Message-ID: <20140414.132504.1498251081471915712.davem@davemloft.net>
References: <1397463442-9150-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, Stuart_Hayes@Dell.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56412 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbaDNRZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 13:25:06 -0400
In-Reply-To: <1397463442-9150-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Mon, 14 Apr 2014 11:17:22 +0300

> Fix in commit [1] is not sufficient since a deferred VF initialization
> could happen after pci_enable_sriov() is finished, but before the PF is
> fully initialized.
> Need to prevent VFs from initializing till the PF is fully ready and
> comm channel is operational.
> 
> [1] - 9798935 "net/mlx4_core: mlx4_init_slave() shouldn't access comm
>       channel before PF is ready"
> 
> CC: Stuart Hayes <Stuart_Hayes@Dell.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
> Changes from V0:
> - Updated patch after commit befdf89: "net/mlx4_core: Preserve pci_dev_data
>   after __mlx4_remove_one()"

Applied, thanks.
