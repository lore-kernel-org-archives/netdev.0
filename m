From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2 0/3] mlx5 driver fixes for 4.5-rc2
Date: Tue, 16 Feb 2016 15:22:14 -0500 (EST)
Message-ID: <20160216.152214.2268006538747996254.davem@davemloft.net>
References: <1455022664-15202-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, matanb@mellanox.com,
	eranbe@mellanox.com, majd@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39485 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754932AbcBPUWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 15:22:16 -0500
In-Reply-To: <1455022664-15202-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Tue,  9 Feb 2016 14:57:41 +0200

> We added here a patch from Matan and Alaa for addressing Linus comments on
> the mess w.r.t reserved field names in the driver/firmware auto-generated file.
> 
> Once the patch hits linus tree, we'll ask Doug to rebase his tree on that
> rc so both net-next and rdma-next development for 4.6 will be done under
> the fixed robust form.
> 
> Also provided two patches that addresses the dynamic ndo initialization
> issue of mlx5e netdevice.
> 
> Or and Saeed.
> 
> changes from V1: (Only first patch was changed)
> In this V we fixed the issues addressed in Or's previous e-mail.
> 	1. Offsets took into account two dimensional u8 arrays
> 	2. Offsets took into account nesting unions and structs
> 	3. Offsets for unions
> 	4. Offsets for any reserved field

Series applied, thanks.
