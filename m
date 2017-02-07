From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-next] mlxsw: add psample dependency for spectrum
Date: Tue, 07 Feb 2017 11:44:25 -0500 (EST)
Message-ID: <20170207.114425.341399611687898005.davem@davemloft.net>
References: <20170206162642.693506-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, idosch@mellanox.com, vadimp@mellanox.com,
        eladr@mellanox.com, cera@cera.cz, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170206162642.693506-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon,  6 Feb 2017 17:26:30 +0100

> When PSAMPLE is a loadable module, spectrum must not be built-in:
> 
> drivers/net/built-in.o: In function `mlxsw_sp_rx_listener_sample_func':
> spectrum.c:(.text+0xe357e): undefined reference to `psample_sample_packet'
> 
> This adds a Kconfig dependency to enforce usable configurations.
> 
> Fixes: 98d0f7b9acda ("mlxsw: spectrum: Add packet sample offloading support")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
