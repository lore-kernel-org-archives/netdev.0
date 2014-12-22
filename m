From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V1] net/mlx4_en: Doorbell is byteswapped in Little
 Endian archs
Date: Mon, 22 Dec 2014 16:34:11 -0500 (EST)
Message-ID: <20141222.163411.1556501830218972086.davem@davemloft.net>
References: <1419236517-15666-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	yevgenyp@mellanox.com, weiyang@linux.vnet.ibm.com,
	david.laight@aculab.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755346AbaLVVeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 16:34:14 -0500
In-Reply-To: <1419236517-15666-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Mon, 22 Dec 2014 10:21:57 +0200

> iowrite32() will byteswap it's argument on big endian archs.
> iowrite32be() will byteswap on little endian archs.
> Since we don't want to do this unnecessary byteswap on the fast path,
> doorbell is stored in the NIC's native endianness. Using the right
> iowrite() according to the arch endianness.
> 
> CC: Wei Yang <weiyang@linux.vnet.ibm.com>
> CC: David Laight <david.laight@aculab.com>
> Fixes: 6a4e812 ("net/mlx4_en: Avoid calling bswap in tx fast path")
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied and queued up for -stable, thanks.
