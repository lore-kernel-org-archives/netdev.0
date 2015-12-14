From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v5 04/19] net: usnic: use __ethtool_get_settings
Date: Mon, 14 Dec 2015 13:03:51 -0800
Message-ID: <1450127046-4573-5-git-send-email-ddecotig@gmail.com>
References: <1450127046-4573-1-git-send-email-ddecotig@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Joe Perches <joe@perches.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ed Swierk <eswierk@skyportsystems.com>,
	Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	David Decotigny <decot@googlers.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org, linux-mips@linux-mips.org,
	fcoe-devel@open-fcoe.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450127046-4573-1-git-send-email-ddecotig@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>

Signed-off-by: David Decotigny <decot@googlers.com>
---
 drivers/infiniband/hw/usnic/usnic_ib_verbs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/usnic/usnic_ib_verbs.c b/drivers/infiniband/hw/usnic/usnic_ib_verbs.c
index 5b60579..e082170 100644
--- a/drivers/infiniband/hw/usnic/usnic_ib_verbs.c
+++ b/drivers/infiniband/hw/usnic/usnic_ib_verbs.c
@@ -329,7 +329,7 @@ int usnic_ib_query_port(struct ib_device *ibdev, u8 port,
 	usnic_dbg("\n");
 
 	mutex_lock(&us_ibdev->usdev_lock);
-	us_ibdev->netdev->ethtool_ops->get_settings(us_ibdev->netdev, &cmd);
+	__ethtool_get_settings(us_ibdev->netdev, &cmd);
 	memset(props, 0, sizeof(*props));
 
 	props->lid = 0;
-- 
2.6.0.rc2.230.g3dd15c0
