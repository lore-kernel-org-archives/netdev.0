From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4: Check if Granular QoS per VF has been
 enabled before updating QP qos_vport
Date: Mon, 05 Jun 2017 11:32:22 -0400 (EDT)
Message-ID: <20170605.113222.276717739073496151.davem@davemloft.net>
References: <1496648696-5457-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, idos@mellanox.com,
        jackm@dev.mellanox.co.il
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38434 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751112AbdFEPcY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 11:32:24 -0400
In-Reply-To: <1496648696-5457-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Mon,  5 Jun 2017 10:44:56 +0300

> From: Ido Shamay <idos@mellanox.com>
> 
> The Granular QoS per VF feature must be enabled in FW before it can be
> used.
> 
> Thus, the driver cannot modify a QP's qos_vport value (via the UPDATE_QP FW
> command) if the feature has not been enabled -- the FW returns an error if
> this is attempted.
> 
> Fixes: 08068cd5683f ("net/mlx4: Added qos_vport QP configuration in VST mode")
> Signed-off-by: Ido Shamay <idos@mellanox.com>
> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>

Applied.
