From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 19/21] parisc: Convert ipv4_is_<foo> uses to ipv4_addr_<foo>
Date: Thu, 18 Oct 2012 21:15:03 -0700
Message-ID: <39c8e14a8fa7d5a0d50b58dea7950a053c3dadff.1350618012.git.joe@perches.com>
References: <cover.1350618006.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1350618006.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the new ipv4_addr_<foo> functions to be consistent with
the ipv6_addr_<foo> and eth_addr_<foo> style.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/parisc/led.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/parisc/led.c b/drivers/parisc/led.c
index f2f501e..8951fd1 100644
--- a/drivers/parisc/led.c
+++ b/drivers/parisc/led.c
@@ -369,7 +369,7 @@ static __inline__ int led_get_net_activity(void)
 	    struct in_device *in_dev = __in_dev_get_rcu(dev);
 	    if (!in_dev || !in_dev->ifa_list)
 		continue;
-	    if (ipv4_is_loopback(in_dev->ifa_list->ifa_local))
+	    if (ipv4_addr_loopback(in_dev->ifa_list->ifa_local))
 		continue;
 	    stats = dev_get_stats(dev, &temp);
 	    rx_total += stats->rx_packets;
-- 
1.7.8.111.gad25c.dirty
