From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1 0/8] mlx5 driver updates and fixes
Date: Sun, 24 Apr 2016 14:53:12 -0400 (EDT)
Message-ID: <20160424.145312.1338728573480668034.davem@davemloft.net>
References: <1461274387-10653-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, talal@mellanox.com,
	eranbe@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52661 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440AbcDXSxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 14:53:22 -0400
In-Reply-To: <1461274387-10653-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Fri, 22 Apr 2016 00:32:59 +0300

> Changes from V0:
> 	- Dropped: ("net/mlx5e: Reset link modes upon setting speed to zero") 
> 	- Fixed compilation issue introduced to mlx5_ib driver.
> 	- Rebased to df637193906a ('Revert "Prevent NUll pointer dereference with two PHYs on cpsw"')
> 
> This series has few bug fixes for mlx5 core and ethernet driver.
> 
> Eli fixed a wrong static local variable declaration in flow steering API.
> Majd added the support of ConnectX-5 PF and VF and added the support
> for kernel shutdown pci callback for more robust reboot procedures.
> Maor fixed a soft lockup in flow steering.
> Rana fixed a wrog speed define in mlx5 EN driver.
> I also had the chance to introduce some bug fixes in mlx5 EN mtu 
> reporting and handling.

Series applied and...

> For -stable:
> 	net/mlx5_core: Fix soft lockup in steering error flow
> 	net/mlx5e: Device's mtu field is u16 and not int
> 	net/mlx5e: Fix minimum MTU
> 	net/mlx5e: Use vport MTU rather than physical port MTU

queued up for -stable.

Thanks.
