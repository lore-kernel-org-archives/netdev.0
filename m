From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: sctp: prevent checksum.h from double inclusion
Date: Mon,  1 Jul 2013 18:10:36 +0200
Message-ID: <1372695036-10914-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37167 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752975Ab3GAQKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jul 2013 12:10:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The header file checksum.h is missing proper defines that prevents
it from double inclusion.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sctp/checksum.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/net/sctp/checksum.h b/include/net/sctp/checksum.h
index 5a2110d..0cb08e6 100644
--- a/include/net/sctp/checksum.h
+++ b/include/net/sctp/checksum.h
@@ -42,6 +42,9 @@
  * be incorporated into the next SCTP release.
  */
 
+#ifndef __sctp_checksum_h__
+#define __sctp_checksum_h__
+
 #include <linux/types.h>
 #include <net/sctp/sctp.h>
 #include <linux/crc32c.h>
@@ -81,3 +84,5 @@ static inline __le32 sctp_end_cksum(__u32 crc32)
 {
 	return cpu_to_le32(~crc32);
 }
+
+#endif /* __sctp_checksum_h__ */
-- 
1.7.11.7
