From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2 2/6] vxlan: remove duplicated macros
Date: Tue,  2 Feb 2016 18:09:12 +0100
Message-ID: <4134345d675e7ac852fb04960ffcf52905baf7f5.1454432731.git.jbenc@redhat.com>
References: <cover.1454432731.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60926 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933573AbcBBRJ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 12:09:26 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (Postfix) with ESMTPS id 439EDC00356E
	for <netdev@vger.kernel.org>; Tue,  2 Feb 2016 17:09:26 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-49.brq.redhat.com [10.40.204.49])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u12H9NSn003510
	for <netdev@vger.kernel.org>; Tue, 2 Feb 2016 12:09:25 -0500
In-Reply-To: <cover.1454432731.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VNI_HASH_BITS and VNI_HASH_SIZE are defined twice. Remove the extra
definitions.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/vxlan.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 5c64250619c5..234bf1ef2737 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -9,9 +9,6 @@
 #include <linux/udp.h>
 #include <net/dst_metadata.h>
 
-#define VNI_HASH_BITS	10
-#define VNI_HASH_SIZE	(1<<VNI_HASH_BITS)
-
 /*
  * VXLAN Group Based Policy Extension:
  * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
-- 
1.8.3.1
