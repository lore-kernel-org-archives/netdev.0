From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next] vxlan: correct spelling in comments
Date: Thu,  2 Apr 2015 11:17:58 +0900
Message-ID: <1427941078-6383-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:33264 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036AbbDBCSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 22:18:31 -0400
Received: by pacgg7 with SMTP id gg7so69661872pac.0
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 19:18:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix some spelling / typos:
* droppped -> dropped
* asddress -> address
* compatbility -> compatibility

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/vxlan.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index a8d345054d23..b5fecb49a0c6 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -989,7 +989,7 @@ out:
 
 /* Watch incoming packets to learn mapping between Ethernet address
  * and Tunnel endpoint.
- * Return true if packet is bogus and should be droppped.
+ * Return true if packet is bogus and should be dropped.
  */
 static bool vxlan_snoop(struct net_device *dev,
 			union vxlan_addr *src_ip, const u8 *src_mac)
@@ -1085,7 +1085,7 @@ void vxlan_sock_release(struct vxlan_sock *vs)
 EXPORT_SYMBOL_GPL(vxlan_sock_release);
 
 /* Update multicast group membership when first VNI on
- * multicast asddress is brought up
+ * multicast address is brought up
  */
 static int vxlan_igmp_join(struct vxlan_dev *vxlan)
 {
@@ -1229,7 +1229,7 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		 * this as a malformed packet. This behavior diverges from
 		 * VXLAN RFC (RFC7348) which stipulates that bits in reserved
 		 * in reserved fields are to be ignored. The approach here
-		 * maintains compatbility with previous stack code, and also
+		 * maintains compatibility with previous stack code, and also
 		 * is more robust and provides a little more security in
 		 * adding extensions to VXLAN.
 		 */
-- 
2.1.4
