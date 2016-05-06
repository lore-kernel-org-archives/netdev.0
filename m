From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: Fix endianness bug in IPV6 csum
 calculation
Date: Thu, 05 May 2016 23:27:06 -0400 (EDT)
Message-ID: <20160505.232706.406069830279349152.davem@davemloft.net>
References: <1462363233-8598-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, danielj@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37499 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757294AbcEFD1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2016 23:27:09 -0400
In-Reply-To: <1462363233-8598-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Wed,  4 May 2016 15:00:33 +0300

> From: Daniel Jurgens <danielj@mellanox.com>
> 
> Use htons instead of unconditionally byte swapping nexthdr.  On a little
> endian systems shifting the byte is correct behavior, but it results in
> incorrect csums on big endian architectures.
> 
> Fixes: f8c6455bb04b ('net/mlx4_en: Extend checksum offloading by CHECKSUM COMPLETE')
> Signed-off-by: Daniel Jurgens <danielj@mellanox.com>
> Reviewed-by: Carol Soto <clsoto@us.ibm.com>
> Tested-by: Carol Soto <clsoto@us.ibm.com>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>

Applied and queued up for -stable, thanks.
