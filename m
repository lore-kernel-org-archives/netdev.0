From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v4 2/9] net: dsa: mv88e6xxx: drop double ds assignment
Date: Sun, 17 Apr 2016 13:23:56 -0400
Message-ID: <1460913843-7459-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1460913843-7459-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460913843-7459-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Every driver assigns ps->ds even though it gets assigned in the shared
mv88e6xxx_setup_common function. Kill redundancy.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6123.c | 2 --
 drivers/net/dsa/mv88e6131.c | 2 --
 drivers/net/dsa/mv88e6171.c | 2 --
 drivers/net/dsa/mv88e6352.c | 2 --
 4 files changed, 8 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 9701c0f..85537eb 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -79,8 +79,6 @@ static int mv88e6123_setup(struct dsa_switch *ds)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	ps->ds = ds;
-
 	ret = mv88e6xxx_setup_common(ds);
 	if (ret < 0)
 		return ret;
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index fa3a354..4117c9b 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -101,8 +101,6 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	ps->ds = ds;
-
 	ret = mv88e6xxx_setup_common(ds);
 	if (ret < 0)
 		return ret;
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 8d86c9e..ae32875 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -76,8 +76,6 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	ps->ds = ds;
-
 	ret = mv88e6xxx_setup_common(ds);
 	if (ret < 0)
 		return ret;
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index c7fa69c..10c36ab 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -87,8 +87,6 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	ps->ds = ds;
-
 	ret = mv88e6xxx_setup_common(ds);
 	if (ret < 0)
 		return ret;
-- 
2.8.0
