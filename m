From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] mlxsw: fix warnings for big-endian 32-bit dma_addr_t
Date: Wed, 7 Oct 2015 08:43:31 +0200
Message-ID: <20151007064331.GC2152@nanopsycho.orion>
References: <30258520.VaA2vDyUiY@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jiri Pirko <jiri@mellanox.com>,
	Ido Schimmel <idosch@mellanox.com>,
	linux-kernel@vger.kernel.org, Elad Raz <eladr@mellanox.com>,
	Scott Feldman <sfeldma@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <30258520.VaA2vDyUiY@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Oct 06, 2015 at 11:47:44PM CEST, arnd@arndb.de wrote:
>The recently added mlxsw driver produces warnings in ARM
>allmodconfig:
>
>drivers/net/ethernet/mellanox/mlxsw/pci.c: In function 'mlxsw_pci_cmd_exec':
>drivers/net/ethernet/mellanox/mlxsw/pci.c:1585:59: warning: right shift count >= width of type [-Wshift-count-overflow]
>linux/byteorder/big_endian.h:38:51: note: in definition of macro '__cpu_to_be32'
>drivers/net/ethernet/mellanox/mlxsw/pci.c:76:2: note: in expansion of macro 'iowrite32be'
>
>This changes the type of the local variable to u64, which gets rid of the
>warning and seems nicer than adding #ifdefs.
>
>Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>Fixes: eda6500a987a "mlxsw: Add PCI bus implementation"

Acked-by: Jiri Pirko <jiri@mellanox.com>

Thanks!
