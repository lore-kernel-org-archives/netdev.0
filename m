From: Yotam Gigi <yotamg@mellanox.com>
Subject: RE: [PATCH] [net-next] mlxsw: add psample dependency for spectrum
Date: Mon, 6 Feb 2017 16:41:27 +0000
Message-ID: <DB3PR05MB07645B7262AF8259EA80D973AC400@DB3PR05MB0764.eurprd05.prod.outlook.com>
References: <20170206162642.693506-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Vadim Pasternak <vadimp@mellanox.com>,
        Elad Raz <eladr@mellanox.com>, Ivan Vecera <cera@cera.cz>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>, Jiri Pirko <jiri@mellanox.com>,
        "Ido Schimmel" <idosch@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170206162642.693506-1-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] O=
n
>Behalf Of Arnd Bergmann
>Sent: Monday, February 06, 2017 6:27 PM
>To: Jiri Pirko <jiri@mellanox.com>; Ido Schimmel <idosch@mellanox.com>
>Cc: Arnd Bergmann <arnd@arndb.de>; David S. Miller <davem@davemloft.net>;
>Vadim Pasternak <vadimp@mellanox.com>; Elad Raz <eladr@mellanox.com>; Ivan
>Vecera <cera@cera.cz>; netdev@vger.kernel.org; linux-kernel@vger.kernel.or=
g
>Subject: [PATCH] [net-next] mlxsw: add psample dependency for spectrum
>
>When PSAMPLE is a loadable module, spectrum must not be built-in:
>
>drivers/net/built-in.o: In function `mlxsw_sp_rx_listener_sample_func':
>spectrum.c:(.text+0xe357e): undefined reference to `psample_sample_packet'
>
>This adds a Kconfig dependency to enforce usable configurations.
>
>Fixes: 98d0f7b9acda ("mlxsw: spectrum: Add packet sample offloading suppor=
t")
>Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Yotam Gigi <yotamg@mellanox.com>

>---
> drivers/net/ethernet/mellanox/mlxsw/Kconfig | 1 +
> 1 file changed, 1 insertion(+)
>
>diff --git a/drivers/net/ethernet/mellanox/mlxsw/Kconfig
>b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
>index 76a7574c3c7d..ef23eaedc2ff 100644
>--- a/drivers/net/ethernet/mellanox/mlxsw/Kconfig
>+++ b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
>@@ -73,6 +73,7 @@ config MLXSW_SWITCHX2
> config MLXSW_SPECTRUM
> 	tristate "Mellanox Technologies Spectrum support"
> 	depends on MLXSW_CORE && MLXSW_PCI && NET_SWITCHDEV &&
>VLAN_8021Q
>+	depends on PSAMPLE || PSAMPLE=3Dn
> 	select PARMAN
> 	default m
> 	---help---
>--
>2.9.0
