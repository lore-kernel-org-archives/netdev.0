From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: Fixed crash when port type is changed
Date: Thu, 07 Nov 2013 19:14:18 -0500 (EST)
Message-ID: <20131107.191418.2145129150067281446.davem@davemloft.net>
References: <1383815310-19116-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755102Ab3KHAOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 19:14:20 -0500
In-Reply-To: <1383815310-19116-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu,  7 Nov 2013 11:08:30 +0200

> timecounter_init() was was called only after first potential
> timecounter_read().
> Moved mlx4_en_init_timestamp() before mlx4_en_init_netdev()
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
> Please pull into -stable for kernels >= 3.10

Applied and queued up for -stable, thanks.
