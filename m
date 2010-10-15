From: Wan ZongShun <mcuos.com@gmail.com>
Subject: [PATCH] net/nuc900: change dev_warn to dev_dbg when link down occurs
Date: Fri, 15 Oct 2010 23:00:23 +0800
Message-ID: <4CB86C87.5010207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, yachen@nuvoton.com,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

When I didnot connect the net cable, the warning infos are always showed,
so I change the dev_warn to dev_dbg.

Signed-off-by: Wan ZongShun <mcuos.com@gmail.com>

---
  drivers/net/arm/w90p910_ether.c |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/arm/w90p910_ether.c b/drivers/net/arm/w90p910_ether.c
index 4545d5a..98f8ada 100644
--- a/drivers/net/arm/w90p910_ether.c
+++ b/drivers/net/arm/w90p910_ether.c
@@ -213,7 +213,7 @@ static void update_linkspeed(struct net_device *dev)
  	if (!mii_link_ok(&ether->mii)) {
  		ether->linkflag = 0x0;
  		netif_carrier_off(dev);
-		dev_warn(&pdev->dev, "%s: Link down.\n", dev->name);
+		dev_dbg(&pdev->dev, "%s: Link down.\n", dev->name);
  		return;
  	}

-- 
1.6.3.3
