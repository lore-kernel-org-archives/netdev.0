From: "Zhang, Sonic" <Sonic.Zhang@analog.com>
Subject: RE: [RFC PATCH 08/17] drivers/net/bfin_mac: Don't unnecessarily
 reset the PHY
Date: Tue, 25 Oct 2011 03:26:50 -0400
Message-ID: <DB904C5425BA6F4E8424B3B51A1414D16D3BA945D1@NWD2CMBX1.ad.analog.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
 <1319144425-15547-9-git-send-email-Kyle.D.Moffett@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@conan.davemloft.net>,
	Mike Frysinger <vapier@gentoo.org>,
	Tobias Klauser <tklauser@distanz.ch>,
	"uclinux-dist-devel@blackfin.uclinux.org"
	<uclinux-dist-devel@blackfin.uclinux.org>
To: Kyle Moffett <Kyle.D.Moffett@boeing.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319144425-15547-9-git-send-email-Kyle.D.Moffett@boeing.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acked-by: Sonic Zhang <sonic.zhang@analog.com>


Sonic

>-----Original Message-----
>From: Kyle Moffett [mailto:Kyle.D.Moffett@boeing.com]
>Sent: Friday, October 21, 2011 5:00 AM
>To: linux-kernel@vger.kernel.org; netdev@vger.kernel.org
>Cc: Kyle Moffett; David S. Miller; Mike Frysinger; Zhang,
>Sonic; Tobias Klauser; uclinux-dist-devel@blackfin.uclinux.org
>Subject: [RFC PATCH 08/17] drivers/net/bfin_mac: Don't
>unnecessarily reset the PHY
>
>The PHY is already reset during driver probing, and this
>manual reset afterwards will wipe out board-specific PHY
>fixups and driver-specific
>phy->drv->config_init() register tweaks.
>
>Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
>---
> drivers/net/bfin_mac.c |    1 -
> 1 files changed, 0 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
>index 6c019e1..1427ec3 100644
>--- a/drivers/net/bfin_mac.c
>+++ b/drivers/net/bfin_mac.c
>@@ -1402,7 +1402,6 @@ static int bfin_mac_open(struct net_device *dev)
>               return ret;
>
>       phy_start(lp->phydev);
>-      phy_write(lp->phydev, MII_BMCR, BMCR_RESET);
>       setup_system_regs(dev);
>       setup_mac_addr(dev->dev_addr);
>
>--
>1.7.2.5
>
>
>
