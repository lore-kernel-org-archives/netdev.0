From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] Doc: networking: 6lowpan: Fix typo in 6lowpan.txt
Date: Wed, 18 Nov 2015 01:12:21 +0900
Message-ID: <1447776741-25157-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: corbet@lwn.net, linux-kernel@vger.kernel.org, alex.aring@gmail.com,
	marcel@holtmann.org, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fix spelling typos in 6lowpan.txt

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 Documentation/networking/6lowpan.txt | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/6lowpan.txt b/Documentation/networking/6lowpan.txt
index a7dc7e9..2e5a939 100644
--- a/Documentation/networking/6lowpan.txt
+++ b/Documentation/networking/6lowpan.txt
@@ -24,10 +24,10 @@ enum lowpan_lltypes.
 
 Example to evaluate the private usually you can do:
 
-static inline sturct lowpan_priv_foobar *
+static inline struct lowpan_priv_foobar *
 lowpan_foobar_priv(struct net_device *dev)
 {
-	return (sturct lowpan_priv_foobar *)lowpan_priv(dev)->priv;
+	return (struct lowpan_priv_foobar *)lowpan_priv(dev)->priv;
 }
 
 switch (dev->type) {
-- 
2.6.3.368.gf34be46
