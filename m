From: Barry Grussling <barry@grussling.com>
Subject: [PATCH V2 4/4] DSA: Convert spaces to tabs where appropriate
Date: Tue,  8 Jan 2013 18:05:56 -0800
Message-ID: <1357697156-5767-5-git-send-email-barry@grussling.com>
References: <1357697156-5767-1-git-send-email-barry@grussling.com>
Cc: Barry Grussling <barry@grussling.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f49.google.com ([209.85.210.49]:35292 "EHLO
	mail-da0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851Ab3AICGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 21:06:19 -0500
Received: by mail-da0-f49.google.com with SMTP id v40so482804dad.8
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 18:06:18 -0800 (PST)
In-Reply-To: <1357697156-5767-1-git-send-email-barry@grussling.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barry Grussling <barry@grussling.com>

Fix DSA whitespace issues reported by checkpatch.pl

Signed-off-by: Barry Grussling <barry@grussling.com>
---
 drivers/net/dsa/mv88e6xxx.c |   44 +++++++++++++++++++++----------------------
 drivers/net/dsa/mv88e6xxx.h |    2 +-
 2 files changed, 23 insertions(+), 23 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 3756c74..17314ed 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -205,10 +205,10 @@ static int mv88e6xxx_ppu_disable(struct dsa_switch *ds)
 
 	timeout = jiffies + 1 * HZ;
 	while (time_before(jiffies, timeout)) {
-	        ret = REG_READ(REG_GLOBAL, 0x00);
+		ret = REG_READ(REG_GLOBAL, 0x00);
 		usleep_range(1000, 2000);
-	        if ((ret & 0xc000) != 0xc000)
-	                return 0;
+		if ((ret & 0xc000) != 0xc000)
+			return 0;
 	}
 
 	return -ETIMEDOUT;
@@ -224,10 +224,10 @@ static int mv88e6xxx_ppu_enable(struct dsa_switch *ds)
 
 	timeout = jiffies + 1 * HZ;
 	while (time_before(jiffies, timeout)) {
-	        ret = REG_READ(REG_GLOBAL, 0x00);
+		ret = REG_READ(REG_GLOBAL, 0x00);
 		usleep_range(1000, 2000);
-	        if ((ret & 0xc000) == 0xc000)
-	                return 0;
+		if ((ret & 0xc000) == 0xc000)
+			return 0;
 	}
 
 	return -ETIMEDOUT;
@@ -239,11 +239,11 @@ static void mv88e6xxx_ppu_reenable_work(struct work_struct *ugly)
 
 	ps = container_of(ugly, struct mv88e6xxx_priv_state, ppu_work);
 	if (mutex_trylock(&ps->ppu_mutex)) {
-	        struct dsa_switch *ds = ((struct dsa_switch *)ps) - 1;
+		struct dsa_switch *ds = ((struct dsa_switch *)ps) - 1;
 
-	        if (mv88e6xxx_ppu_enable(ds) == 0)
-	                ps->ppu_disabled = 0;
-	        mutex_unlock(&ps->ppu_mutex);
+		if (mv88e6xxx_ppu_enable(ds) == 0)
+			ps->ppu_disabled = 0;
+		mutex_unlock(&ps->ppu_mutex);
 	}
 }
 
@@ -267,15 +267,15 @@ static int mv88e6xxx_ppu_access_get(struct dsa_switch *ds)
 	 * it.
 	 */
 	if (!ps->ppu_disabled) {
-	        ret = mv88e6xxx_ppu_disable(ds);
-	        if (ret < 0) {
-	                mutex_unlock(&ps->ppu_mutex);
-	                return ret;
-	        }
-	        ps->ppu_disabled = 1;
+		ret = mv88e6xxx_ppu_disable(ds);
+		if (ret < 0) {
+			mutex_unlock(&ps->ppu_mutex);
+			return ret;
+		}
+		ps->ppu_disabled = 1;
 	} else {
-	        del_timer(&ps->ppu_timer);
-	        ret = 0;
+		del_timer(&ps->ppu_timer);
+		ret = 0;
 	}
 
 	return ret;
@@ -307,8 +307,8 @@ int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum)
 
 	ret = mv88e6xxx_ppu_access_get(ds);
 	if (ret >= 0) {
-	        ret = mv88e6xxx_reg_read(ds, addr, regnum);
-	        mv88e6xxx_ppu_access_put(ds);
+		ret = mv88e6xxx_reg_read(ds, addr, regnum);
+		mv88e6xxx_ppu_access_put(ds);
 	}
 
 	return ret;
@@ -321,8 +321,8 @@ int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
 
 	ret = mv88e6xxx_ppu_access_get(ds);
 	if (ret >= 0) {
-	        ret = mv88e6xxx_reg_write(ds, addr, regnum, val);
-	        mv88e6xxx_ppu_access_put(ds);
+		ret = mv88e6xxx_reg_write(ds, addr, regnum, val);
+		mv88e6xxx_ppu_access_put(ds);
 	}
 
 	return ret;
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 029e13d..911ede5 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -49,7 +49,7 @@ struct mv88e6xxx_hw_stat {
 int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg);
 int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg);
 int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
-                          int reg, u16 val);
+			  int reg, u16 val);
 int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val);
 int mv88e6xxx_config_prio(struct dsa_switch *ds);
 int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr);
-- 
1.7.9.5
