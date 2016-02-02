From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 1/5] vxlan: cleanup types
Date: Tue,  2 Feb 2016 11:13:21 +0100
Message-ID: <c0cc647aab6b7439143c7364ecebb974e40764f1.1454407418.git.jbenc@redhat.com>
References: <cover.1454407418.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37227 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754443AbcBBKNv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 05:13:51 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id 0BFC6804FE
	for <netdev@vger.kernel.org>; Tue,  2 Feb 2016 10:13:51 +0000 (UTC)
Received: from griffin.localdomain (ovpn-204-27.brq.redhat.com [10.40.204.27])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u12ADmYf027928
	for <netdev@vger.kernel.org>; Tue, 2 Feb 2016 05:13:50 -0500
In-Reply-To: <cover.1454407418.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

include/net/vxlan.h is a kernel header, no need to prefix fixed size types
with double underscore.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/vxlan.h | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 0fb86442544b..5c64250619c5 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -30,15 +30,15 @@
  * [0] https://tools.ietf.org/html/draft-smith-vxlan-group-policy
  */
 struct vxlanhdr_gbp {
-	__u8	vx_flags;
+	u8	vx_flags;
 #ifdef __LITTLE_ENDIAN_BITFIELD
-	__u8	reserved_flags1:3,
+	u8	reserved_flags1:3,
 		policy_applied:1,
 		reserved_flags2:2,
 		dont_learn:1,
 		reserved_flags3:1;
 #elif defined(__BIG_ENDIAN_BITFIELD)
-	__u8	reserved_flags1:1,
+	u8	reserved_flags1:1,
 		dont_learn:1,
 		reserved_flags2:2,
 		policy_applied:1,
@@ -138,10 +138,10 @@ struct vxlan_config {
 	int			remote_ifindex;
 	int			mtu;
 	__be16			dst_port;
-	__u16			port_min;
-	__u16			port_max;
-	__u8			tos;
-	__u8			ttl;
+	u16			port_min;
+	u16			port_max;
+	u8			tos;
+	u8			ttl;
 	u32			flags;
 	unsigned long		age_interval;
 	unsigned int		addrmax;
-- 
1.8.3.1
