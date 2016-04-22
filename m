From: Andrew Goodbody <andrew.goodbody@cambrionix.com>
Subject: RE: [PATCH net v2 0/3] drivers: net: cpsw: phy-handle fixes
Date: Fri, 22 Apr 2016 13:44:14 +0000
Message-ID: <80ea1660b86143fab7a9805749f06bd2@THHSTE15D2BE2.hs20.net>
References: <1461261035-5578-1-git-send-email-drivshin.allworx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Mugunthan V N" <mugunthanvnm@ti.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Nicolas Chauvet <kwizart@gmail.com>
To: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461261035-5578-1-git-send-email-drivshin.allworx@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: David Rivshin <drivshin@allworx.com>
> 
> The first patch fixes a bug that makes dual_emac mode break if either slave
> uses the phy-handle property in the devicetree.
> 
> The second patch fixes some cosmetic problems with error messages, and
> also makes the binding documentation more explicit.
> 
> The third patch cleans up the fixed-link case to work like the now-fixed phy-
> handle case.
> 
> I have tested on the following hardware configurations:
>  - (EVMSK) dual emac, phy_id property in both slaves
>  - (EVMSK) dual emac, phy-handle property in both slaves
>  - (BeagleBoneBlack) single emac, phy_id property
>  - (custom) single emac, fixed-link subnode
> 
> Nicolas Chauvet reported testing on an HP t410 (dm8148).
> 
> Markus Brunner reported testing v1 on the following [1]:
>  - emac0 with phy_id and emac1 with fixed phy
>  - emac0 with phy-handle and emac1 with fixed phy
>  - emac0 with fixed phy and emac1 with fixed phy
> 
> 
> Changes since v1 [2]:
> - Rebased
> - Added Tested-by from Nicolas Chauvet on all patches
> - Added Acked-by from Rob Herring for the binding change in patch 2 [3]
> 
> [1] http://www.spinics.net/lists/netdev/msg357890.html
> [2] http://www.spinics.net/lists/netdev/msg357772.html
> [3] http://www.spinics.net/lists/netdev/msg358254.html
> 
> David Rivshin (3):
>   drivers: net: cpsw: fix parsing of phy-handle DT property in dual_emac
>     config
>   drivers: net: cpsw: fix error messages when using phy-handle DT
>     property
>   drivers: net: cpsw: use of_phy_connect() in fixed-link case
> 
>  Documentation/devicetree/bindings/net/cpsw.txt |  4 +--
>  drivers/net/ethernet/ti/cpsw.c                 | 41 +++++++++++++-------------
>  drivers/net/ethernet/ti/cpsw.h                 |  1 +
>  3 files changed, 23 insertions(+), 23 deletions(-)
> 
> --
> 2.5.5

Tested on hardware with 2 PHYs but not dual_emac mode, DT has phy-handle entries.

Tested-by: Andrew Goodbody <andrew.goodbody@cambrionix.com>
