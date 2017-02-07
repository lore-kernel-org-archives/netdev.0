From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] [net-next] mlxsw: add psample dependency for spectrum
Date: Tue, 7 Feb 2017 10:47:01 +0100
Message-ID: <20170207094701.GB2066@nanopsycho>
References: <20170206162642.693506-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Vadim Pasternak <vadimp@mellanox.com>,
        Elad Raz <eladr@mellanox.com>, Ivan Vecera <cera@cera.cz>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170206162642.693506-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Feb 06, 2017 at 05:26:30PM CET, arnd@arndb.de wrote:
>When PSAMPLE is a loadable module, spectrum must not be built-in:
>
>drivers/net/built-in.o: In function `mlxsw_sp_rx_listener_sample_func':
>spectrum.c:(.text+0xe357e): undefined reference to `psample_sample_packet'
>
>This adds a Kconfig dependency to enforce usable configurations.
>
>Fixes: 98d0f7b9acda ("mlxsw: spectrum: Add packet sample offloading support")
>Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Jiri Pirko <jiri@mellanox.com>
