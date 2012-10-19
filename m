From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 18/21] ath6kl: Convert ipv4_is_<foo> uses to ipv4_addr_<foo>
Date: Thu, 18 Oct 2012 21:15:02 -0700
Message-ID: <24a0970cbeb1e5841468535182457d9586ab21a3.1350618012.git.joe@perches.com>
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
 drivers/net/wireless/ath/ath6kl/wmi.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/wmi.c b/drivers/net/wireless/ath/ath6kl/wmi.c
index c30ab4b..a5624f5 100644
--- a/drivers/net/wireless/ath/ath6kl/wmi.c
+++ b/drivers/net/wireless/ath/ath6kl/wmi.c
@@ -2547,8 +2547,8 @@ int ath6kl_wmi_set_ip_cmd(struct wmi *wmi, u8 if_idx,
 	int ret;
 
 	/* Multicast address are not valid */
-	if (ipv4_is_multicast(ips0) ||
-	    ipv4_is_multicast(ips1))
+	if (ipv4_addr_multicast(ips0) ||
+	    ipv4_addr_multicast(ips1))
 		return -EINVAL;
 
 	skb = ath6kl_wmi_get_new_buf(sizeof(struct wmi_set_ip_cmd));
-- 
1.7.8.111.gad25c.dirty
