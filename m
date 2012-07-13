From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 5/8] drivers/net: Use eth_random_addr
Date: Thu, 12 Jul 2012 22:33:09 -0700
Message-ID: <c983f8cd5e53f9c6d4aac8aa5bb94878b13958ec.1342157022.git.joe@perches.com>
References: <1341968967.13724.23.camel@joe2Laptop>
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, wimax@linuxwimax.org
To: David Miller <davem@davemloft.net>,
	Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	linux-wimax@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341968967.13724.23.camel@joe2Laptop>
In-Reply-To: <cover.1342157022.git.joe@perches.com>
References: <cover.1342157022.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the existing uses of random_ether_addr to
the new eth_random_addr.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tun.c                 |    2 +-
 drivers/net/wimax/i2400m/driver.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 987aeef..961fad1 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -22,7 +22,7 @@
  *    Add TUNSETLINK ioctl to set the link encapsulation
  *
  *  Mark Smith <markzzzsmith@yahoo.com.au>
- *    Use random_ether_addr() for tap MAC address.
+ *    Use eth_random_addr() for tap MAC address.
  *
  *  Harald Roelle <harald.roelle@ifi.lmu.de>  2004/04/20
  *    Fixes in packet dropping, queue length setting and queue wakeup.
diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 47cae71..01d400d 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -897,7 +897,7 @@ int i2400m_setup(struct i2400m *i2400m, enum i2400m_bri bm_flags)
 	result = i2400m_read_mac_addr(i2400m);
 	if (result < 0)
 		goto error_read_mac_addr;
-	random_ether_addr(i2400m->src_mac_addr);
+	eth_random_addr(i2400m->src_mac_addr);
 
 	i2400m->pm_notifier.notifier_call = i2400m_pm_notifier;
 	register_pm_notifier(&i2400m->pm_notifier);
-- 
1.7.8.111.gad25c.dirty
