From: Christian Dietrich <qy03fugy@stud.informatik.uni-erlangen.de>
Subject: [PATCH 06/14] drivers/net: Removing undead ifdef CHELSIO_T1_1G
Date: Mon, 6 Sep 2010 16:36:25 +0200
Message-ID: <fd089f3e72b01fc29faf8113606354f6c423f141.1283782701.git.qy03fugy@stud.informatik.uni-erlangen.de>
References: <cover.1283782698.git.qy03fugy@stud.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vamos-dev@i4.informatik.uni-erlangen.de
To: "David S. Miller" <davem@davemloft.net>,
	Roland Dreier <rolandd@cisco.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1283782698.git.qy03fugy@stud.informatik.uni-erlangen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CHELSIO_T1_1G ifdef isn't necessary at this point, because it is
checked in an outer ifdef level already and has no effect here.

Signed-off-by: Christian Dietrich <qy03fugy@stud.informatik.uni-erlangen.de>
---
 drivers/net/chelsio/subr.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/chelsio/subr.c b/drivers/net/chelsio/subr.c
index 599d178..63ebf76 100644
--- a/drivers/net/chelsio/subr.c
+++ b/drivers/net/chelsio/subr.c
@@ -314,14 +314,12 @@ static int mi1_mdio_write(struct net_device *dev, int phy_addr, int mmd_addr,
 	return 0;
 }
 
-#if defined(CONFIG_CHELSIO_T1_1G)
 static const struct mdio_ops mi1_mdio_ops = {
 	.init = mi1_mdio_init,
 	.read = mi1_mdio_read,
 	.write = mi1_mdio_write,
 	.mode_support = MDIO_SUPPORTS_C22
 };
-#endif
 
 #endif
 
-- 
1.7.0.4
