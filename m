From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Revert "net/mlx4_en: Fix panic during reboot"
Date: Wed, 09 Nov 2016 13:30:36 -0500 (EST)
Message-ID: <20161109.133036.2136919717437832633.davem@davemloft.net>
References: <1478448306-28738-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, eugenia@mellanox.com,
        saeedm@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38554 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751095AbcKISah (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 13:30:37 -0500
In-Reply-To: <1478448306-28738-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Sun,  6 Nov 2016 18:05:06 +0200

> This reverts commit 9d2afba058722d40cc02f430229c91611c0e8d16.
> 
> The original issue would possibly exist if an external module
> tried calling our "ethtool_ops" without checking if it still
> exists.
> 
> The right way of solving it is by simply doing the check in
> the caller side.
> Currently, no action is required as there's no such use case.
> 
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>

Applied.
