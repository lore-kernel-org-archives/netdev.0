From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net/mlx4_en: Add accelerated RFS support
Date: Wed, 18 Jul 2012 11:41:58 -0700 (PDT)
Message-ID: <20120718.114158.2161516212050365274.davem@davemloft.net>
References: <1342621162-18498-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, netdev@vger.kernel.org, oren@mellanox.com,
	yevgenyp@mellanox.com, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755327Ab2GRSl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:41:59 -0400
In-Reply-To: <1342621162-18498-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 18 Jul 2012 17:19:18 +0300

> This series from Amir Vadai adds support for Accelerated RFS 
> to the mlx4_en Ethernet driver.
> 
> The code uses the Accelerated RFS infrastructure and HW flow steering 
> to keep CPU affinity of rx interrupts and applications per TCP stream.
> 
> To do so, we had to add little protection to cpu_rmap.h against double 
> inclusion. Also, added linking between CPU to IRQ using rmap in the 
> mlx4_core driver.

Please use CONFIG_RFS_ACCEL consistently to protect this feature
in your driver sources.

Using CPU_RMAP in a few places is inconsistent, and not what other
drivers do.

Thanks.
