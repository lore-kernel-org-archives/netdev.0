From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 2/5] vxlan: remove duplicated macros
Date: Tue,  2 Feb 2016 11:13:22 +0100
Message-ID: <a8b60c9b6d17b5e68f425a5c3ae3c51ffc085c8b.1454407418.git.jbenc@redhat.com>
References: <cover.1454407418.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37203 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754736AbcBBKNw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 05:13:52 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id 03992344DED
	for <netdev@vger.kernel.org>; Tue,  2 Feb 2016 10:13:52 +0000 (UTC)
Received: from griffin.localdomain (ovpn-204-27.brq.redhat.com [10.40.204.27])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u12ADmYg027928
	for <netdev@vger.kernel.org>; Tue, 2 Feb 2016 05:13:51 -0500
In-Reply-To: <cover.1454407418.git.jbenc@redhat.com>
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
