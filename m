From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/10] net/atm: Remove unnecessary casts of netdev_priv
Date: Mon, 15 Nov 2010 13:12:33 -0800
Message-ID: <0953cd1e1042f41ae839f5b9e4adaffd555c71eb.1289855436.git.joe@perches.com>
References: <cover.1289855436.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1289855436.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/br2684.c |    2 +-
 net/atm/lec.c    |    3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index ad2b232..fce2eae 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -97,7 +97,7 @@ static LIST_HEAD(br2684_devs);
 
 static inline struct br2684_dev *BRPRIV(const struct net_device *net_dev)
 {
-	return (struct br2684_dev *)netdev_priv(net_dev);
+	return netdev_priv(net_dev);
 }
 
 static inline struct net_device *list_entry_brdev(const struct list_head *le)
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 181d70c..179e04b 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -816,8 +816,7 @@ static int lec_mcast_attach(struct atm_vcc *vcc, int arg)
 	if (arg < 0 || arg >= MAX_LEC_ITF || !dev_lec[arg])
 		return -EINVAL;
 	vcc->proto_data = dev_lec[arg];
-	return lec_mcast_make((struct lec_priv *)netdev_priv(dev_lec[arg]),
-				vcc);
+	return lec_mcast_make(netdev_priv(dev_lec[arg]), vcc);
 }
 
 /* Initialize device. */
-- 
1.7.3.1.g432b3.dirty
