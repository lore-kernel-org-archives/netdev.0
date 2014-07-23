From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] Mellanox driver update Jul-22-2014
Date: Tue, 22 Jul 2014 19:54:14 -0700 (PDT)
Message-ID: <20140722.195414.658758946125876535.davem@davemloft.net>
References: <1406033052-16550-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54012 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753988AbaGWCyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 22:54:15 -0400
In-Reply-To: <1406033052-16550-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Tue, 22 Jul 2014 15:44:08 +0300

> This patchset contains a fix by Eyal to fix a bug in mlx4_en with bonding
> alb/tlb mode.
> The second patch, by me, is an ethtool private flag that enable turning off the
> BlueFlame hardware feature.
> The last two patches, introduce a new low memory profile for mlx4_en and
> mlx4_core. This mode is useful when running from a limited resources
> environment, like kdump. This will reduce the memory consumed by both drivers
> from more than 100M to ~30M.
> 
> This patchset was applied and tested on commit 575a193 ("net: mvpp2: Fix error
> return code in mvpp2_probe")

Series applied, thanks.
