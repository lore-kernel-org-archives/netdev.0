From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH v2 0/3] net: ethtool: add
 ethtool_op_{get|set}_link_ksettings
Date: Mon, 9 May 2016 01:57:56 +0000
Message-ID: <VI1PR0401MB1855DC34F07A1B44E7A6369EFF700@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1462743877-31738-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"kan.liang@intel.com" <kan.liang@intel.com>,
	"decot@googlers.com" <decot@googlers.com>,
	"aduyck@mirantis.com" <aduyck@mirantis.com>,
	"jiri@mellanox.com" <jiri@mellanox.com>,
	"jacob.e.keller@intel.com" <jacob.e.keller@intel.com>,
	"tom@herbertland.com" <tom@herbertland.com>,
	"andrew@lunn.ch" <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462743877-31738-1-git-send-email-tremyfr@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fom: Philippe Reynes <tremyfr@gmail.com> Sent: Monday, May 09, 2016 5:45 AM
> To: Fugang Duan <fugang.duan@nxp.com>; davem@davemloft.net;
> ben@decadent.org.uk; kan.liang@intel.com; decot@googlers.com;
> aduyck@mirantis.com; jiri@mellanox.com; jacob.e.keller@intel.com;
> tom@herbertland.com; andrew@lunn.ch
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Philippe Reynes
> <tremyfr@gmail.com>
> Subject: [PATCH v2 0/3] net: ethtool: add ethtool_op_{get|set}_link_ksettings
> 
> Ethtool callbacks {get|set}_link_ksettings may be the same for many drivers. So
> we add two generics callbacks ethtool_op_{get|set}_link_ksettings.
> 
> To use those generics callbacks, the ethernet driver must use the pointer
> phydev contained in struct net_device, and not use a private structure to store
> this pointer.
> 
> Changelog:
> v2:
> - use generic function instead of macro
> - ethernet driver use the pointer phydev provided by struct net_device
>   Those idea were provided by Ben Hutchings,
>   and Florian Fainelli acknowledge them.
> 
> Philippe Reynes (3):
>   net: core: ethtool: add ethtool_op_{get|set}_link_ksettings
>   net: ethernet: fec: use phydev from struct net_device
>   net: ethernet: fec: use ethtool_op_{get|set}_link_ksettings
> 
>  drivers/net/ethernet/freescale/fec.h      |    1 -
>  drivers/net/ethernet/freescale/fec_main.c |   71 +++++++++--------------------
>  include/linux/ethtool.h                   |    5 ++
>  net/core/ethtool.c                        |   24 ++++++++++
>  4 files changed, 50 insertions(+), 51 deletions(-)
> 
> --
> 1.7.4.4

Acked-by: Fugang Duan <fugang.duan@nxp.com>
