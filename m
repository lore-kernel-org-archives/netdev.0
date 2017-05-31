From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlxfw: select CONFIG_XZ_DEC
Date: Wed, 31 May 2017 12:53:32 -0400 (EDT)
Message-ID: <20170531.125332.804150363431702680.davem@davemloft.net>
References: <20170530092628.1306028-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yotamg@mellanox.com, idosch@mellanox.com, jiri@mellanox.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170530092628.1306028-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 30 May 2017 11:26:14 +0200

> The new mlxfw code fails to build without the xz library:
> 
> drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.o: In function `mlxfw_mfa2_xz_dec_run':
> :(.text.mlxfw_mfa2_xz_dec_run+0x8): undefined reference to `xz_dec_run'
> drivers/net/ethernet/mellanox/mlxfw/mlxfw_mfa2.o: In function `mlxfw_mfa2_file_component_get':
> :(.text.mlxfw_mfa2_file_component_get+0x218): undefined reference to `xz_dec_init'
> :(.text.mlxfw_mfa2_file_component_get+0x2c0): undefined reference to `xz_dec_end'
> 
> This adds a Kconfig 'select' statement for it, which is also what
> the other user of that library has.
> 
> Fixes: 410ed13cae39 ("Add the mlxfw module for Mellanox firmware flash process")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks Arnd.
