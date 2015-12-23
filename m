From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 1/2] bonding: drop unused to_dev macro in bond_sysfs.c
Date: Wed, 23 Dec 2015 20:42:20 +0800
Message-ID: <2e7e038ba8b7872e9e510aecde073bf944924a51.1450874224.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

to_dev is not used anymore so drop it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 drivers/net/bonding/bond_sysfs.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index f4ae720..313dbac 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -42,7 +42,6 @@
 
 #include <net/bonding.h>
 
-#define to_dev(obj)	container_of(obj, struct device, kobj)
 #define to_bond(cd)	((struct bonding *)(netdev_priv(to_net_dev(cd))))
 
 /* "show" function for the bond_masters attribute.
-- 
2.5.0
