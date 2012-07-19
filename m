From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 0/4] net/mlx4_en: Add accelerated RFS
 support
Date: Thu, 19 Jul 2012 08:34:59 -0700 (PDT)
Message-ID: <20120719.083459.617485160559083500.davem@davemloft.net>
References: <1342686832-21406-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, netdev@vger.kernel.org, oren@mellanox.com,
	yevgenyp@mellanox.com, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45282 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942Ab2GSPfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 11:35:01 -0400
In-Reply-To: <1342686832-21406-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 19 Jul 2012 11:33:48 +0300

> This series from Amir Vadai adds support for Accelerated RFS 
> to the mlx4_en Ethernet driver.
> 
> The code uses the Accelerated RFS infrastructure and HW flow steering 
> to keep CPU affinity of rx interrupts and applications per TCP stream.
> 
> To do so, we had to add little protection to cpu_rmap.h against double 
> inclusion. Also, added linking between CPU to IRQ using rmap in the 
> mlx4_core driver.
> 
> changes from V0:
>  - always use CONFIG_RFS_ACCEL instead of using twice CONFIG_CPU_RMAP directly

Series applied, thanks.
