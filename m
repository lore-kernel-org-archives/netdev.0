From: Ozgur Karatas <okaratas@member.fsf.org>
Subject: [PATCH 130/130] Fixed to checkpatch errors.
Date: Mon, 05 Dec 2016 19:42:27 +0200
Message-ID: <459781480959747@web17h.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: johannes@sipsolutions.net, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Fixed to checkpatch errors.

ERROR: net/wireless/util.c:1787: ERROR: that open brace { should be on the previous line
ERROR: net/wireless/util.c:1792: ERROR: that open brace { should be on the previous line

Signed-off-by: Ozgur Karatas <okaratas@member.fsf.org>
---
 net/wireless/util.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/wireless/util.c b/net/wireless/util.c
index 659b507..f4ac755 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -1783,11 +1783,13 @@ EXPORT_SYMBOL(cfg80211_free_nan_func);
 
 /* See IEEE 802.1H for LLC/SNAP encapsulation/decapsulation */
 /* Ethernet-II snap header (RFC1042 for most EtherTypes) */
-const unsigned char rfc1042_header[] __aligned(2) =
-	{ 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00 };
+const unsigned char rfc1042_header[] __aligned(2) = {
+	0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00
+};
 EXPORT_SYMBOL(rfc1042_header);
 
 /* Bridge-Tunnel header (for EtherTypes ETH_P_AARP and ETH_P_IPX) */
-const unsigned char bridge_tunnel_header[] __aligned(2) =
-	{ 0xaa, 0xaa, 0x03, 0x00, 0x00, 0xf8 };
+const unsigned char bridge_tunnel_header[] __aligned(2) = {
+	0xaa, 0xaa, 0x03, 0x00, 0x00, 0xf8
+};
 EXPORT_SYMBOL(bridge_tunnel_header);
-- 
2.1.4
