From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V1 00/13] mlx4 driver update (+ new VF ndo)
Date: Mon, 15 Jun 2015 17:23:22 -0700 (PDT)
Message-ID: <20150615.172322.97736390268575202.davem@davemloft.net>
References: <1434380348-19005-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, talal@mellanox.com,
	hadarh@mellanox.com, eranbe@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42878 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996AbbFPAXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 20:23:23 -0400
In-Reply-To: <1434380348-19005-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Mon, 15 Jun 2015 17:58:55 +0300

> This series from Eran and Hadar is further dealing with traffic 
> counters in the mlx4 driver, this time mostly around SRIOV.
> 
> We added a new ndo to read the VF counters through the PF netdev 
> netlink infrastructure plus mlx4 implementation for that ndo.
> 
> Or.
> 
> changes from V0:
>   - applied feedback from John to use nested netlink encoding
>     for the VF counters so we can extend it later
>   - add handling of single ported VFs in the mlx4_en driver new ndo
>   - avoid chopping the FW counters from 64 to 32 bits in mlx4_en PF flow

Looks good, series applied, thanks Or.
