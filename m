From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v2] mlxsw: fix warnings for big-endian 32-bit dma_addr_t
Date: Wed, 7 Oct 2015 09:00:37 +0200
Message-ID: <20151007070036.GE2152@nanopsycho.orion>
References: <30258520.VaA2vDyUiY@wuerfel>
 <1444200782.26237.8.camel@perches.com>
 <9933338.DDyBa8BQum@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	davem@davemloft.net, Jiri Pirko <jiri@mellanox.com>,
	Ido Schimmel <idosch@mellanox.com>,
	linux-kernel@vger.kernel.org, Elad Raz <eladr@mellanox.com>,
	Scott Feldman <sfeldma@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9933338.DDyBa8BQum@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Oct 07, 2015 at 08:58:34AM CEST, arnd@arndb.de wrote:
>The recently added mlxsw driver produces warnings in ARM
>allmodconfig:
>
>drivers/net/ethernet/mellanox/mlxsw/pci.c: In function 'mlxsw_pci_cmd_exec':
>drivers/net/ethernet/mellanox/mlxsw/pci.c:1585:59: warning: right shift count >= width of type [-Wshift-count-overflow]
>linux/byteorder/big_endian.h:38:51: note: in definition of macro '__cpu_to_be32'
>drivers/net/ethernet/mellanox/mlxsw/pci.c:76:2: note: in expansion of macro 'iowrite32be'
>
>This uses upper_32_bits() to extract the bits while avoiding that warning.
>
>Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>Acked-by: Jiri Pirko <jiri@mellanox.com>
>Fixes: eda6500a987a "mlxsw: Add PCI bus implementation"
>---
>I've kept Jiri's Ack despite having in effect a completely different
>patch here, as the effect and the changelog is the same for practical purposes.
>Hope that's ok.

It's ok, thanks.
