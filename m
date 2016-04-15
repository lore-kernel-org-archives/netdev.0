From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 1/7] net: dsa: mv88e6xxx: drop double ds assignment
Date: Fri, 15 Apr 2016 19:21:22 -0400
Message-ID: <1460762488-2633-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1460762488-2633-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:36731 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbcDOXV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 19:21:57 -0400
In-Reply-To: <1460762488-2633-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Every driver assigns ps->ds even though it gets assigned in the shared
mv88e6xxx_setup_common function. Kill redundancy.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c | 2 --
 drivers/net/dsa/mv88e6131.c | 2 --
 drivers/net/dsa/mv88e6171.c | 2 --
 drivers/net/dsa/mv88e6352.c | 2 --
 4 files changed, 8 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index c34283d..88a812d 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -76,8 +76,6 @@ static int mv88e6123_setup(struct dsa_switch *ds)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	ps->ds = ds;
-
 	ret = mv88e6xxx_setup_common(ds);
 	if (ret < 0)
 		return ret;
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index f5d75fc..6b2bcb0 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -94,8 +94,6 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	ps->ds = ds;
-
 	ret = mv88e6xxx_setup_common(ds);
 	if (ret < 0)
 		return ret;
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index f562250..40222b0 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -72,8 +72,6 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	ps->ds = ds;
-
 	ret = mv88e6xxx_setup_common(ds);
 	if (ret < 0)
 		return ret;
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index e54ee27..dbd920e 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -84,8 +84,6 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	ps->ds = ds;
-
 	ret = mv88e6xxx_setup_common(ds);
 	if (ret < 0)
 		return ret;
-- 
2.8.0
