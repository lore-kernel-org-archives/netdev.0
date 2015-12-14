From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v5 03/19] net: usnic: remove unused call to ethtool_ops::get_settings
Date: Mon, 14 Dec 2015 13:03:50 -0800
Message-ID: <1450127046-4573-4-git-send-email-ddecotig@gmail.com>
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
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1450127046-4573-1-git-send-email-ddecotig@gmail.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>

Signed-off-by: David Decotigny <decot@googlers.com>
---
 drivers/infiniband/hw/usnic/usnic_ib_verbs.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/infiniband/hw/usnic/usnic_ib_verbs.c b/drivers/infiniband/hw/usnic/usnic_ib_verbs.c
index f8e3211..5b60579 100644
--- a/drivers/infiniband/hw/usnic/usnic_ib_verbs.c
+++ b/drivers/infiniband/hw/usnic/usnic_ib_verbs.c
@@ -269,7 +269,6 @@ int usnic_ib_query_device(struct ib_device *ibdev,
 	struct usnic_ib_dev *us_ibdev = to_usdev(ibdev);
 	union ib_gid gid;
 	struct ethtool_drvinfo info;
-	struct ethtool_cmd cmd;
 	int qp_per_vf;
 
 	usnic_dbg("\n");
@@ -278,7 +277,6 @@ int usnic_ib_query_device(struct ib_device *ibdev,
 
 	mutex_lock(&us_ibdev->usdev_lock);
 	us_ibdev->netdev->ethtool_ops->get_drvinfo(us_ibdev->netdev, &info);
-	us_ibdev->netdev->ethtool_ops->get_settings(us_ibdev->netdev, &cmd);
 	memset(props, 0, sizeof(*props));
 	usnic_mac_ip_to_gid(us_ibdev->ufdev->mac, us_ibdev->ufdev->inaddr,
 			&gid.raw[0]);
-- 
2.6.0.rc2.230.g3dd15c0
