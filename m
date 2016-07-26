From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_core: Check device state before
 unregistering it
Date: Mon, 25 Jul 2016 18:00:44 -0700 (PDT)
Message-ID: <20160725.180044.1478270387772730874.davem@davemloft.net>
References: <1469450533-27494-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, valex@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49464 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753736AbcGZBAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 21:00:45 -0400
In-Reply-To: <1469450533-27494-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Mon, 25 Jul 2016 15:42:13 +0300

> From: Alex Vesker <valex@mellanox.com>
> 
> Verify that the device state is registered before un-registering it.
> This check is required to prevent an OOPS on flows that do
> re-registration of the device and its previous state was
> unregistered.
> 
> Fixes: 225c7b1feef1 ("IB/mlx4: Add a driver Mellanox ConnectX InfiniBand adapters")
> Signed-off-by: Alex Vesker <valex@mellanox.com>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>

Applied.
