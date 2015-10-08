From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] mlxsw: fix warnings for big-endian 32-bit dma_addr_t
Date: Thu, 08 Oct 2015 05:07:19 -0700 (PDT)
Message-ID: <20151008.050719.1791217246493289007.davem@davemloft.net>
References: <30258520.VaA2vDyUiY@wuerfel>
	<1444200782.26237.8.camel@perches.com>
	<9933338.DDyBa8BQum@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org, jiri@mellanox.com,
	idosch@mellanox.com, linux-kernel@vger.kernel.org,
	eladr@mellanox.com, sfeldma@gmail.com,
	linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60968 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755867AbbJHLvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 07:51:32 -0400
In-Reply-To: <9933338.DDyBa8BQum@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 07 Oct 2015 08:58:34 +0200

> The recently added mlxsw driver produces warnings in ARM
> allmodconfig:
> 
> drivers/net/ethernet/mellanox/mlxsw/pci.c: In function 'mlxsw_pci_cmd_exec':
> drivers/net/ethernet/mellanox/mlxsw/pci.c:1585:59: warning: right shift count >= width of type [-Wshift-count-overflow]
> linux/byteorder/big_endian.h:38:51: note: in definition of macro '__cpu_to_be32'
> drivers/net/ethernet/mellanox/mlxsw/pci.c:76:2: note: in expansion of macro 'iowrite32be'
> 
> This uses upper_32_bits() to extract the bits while avoiding that warning.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Acked-by: Jiri Pirko <jiri@mellanox.com>
> Fixes: eda6500a987a "mlxsw: Add PCI bus implementation"

Applied, thanks.
