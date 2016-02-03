From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/3] bridge: mdb: add support for offloaded mdb entries
Date: Wed,  3 Feb 2016 09:57:04 +0100
Message-ID: <1454489826-1858-2-git-send-email-jiri@resnulli.us>
References: <1454489826-1858-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:32867 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755127AbcBCI5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 03:57:10 -0500
Received: by mail-wm0-f51.google.com with SMTP id l66so152938036wml.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 00:57:09 -0800 (PST)
In-Reply-To: <1454489826-1858-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Add new bitmask member 'flags' to br_mdb_entry structure. Adding
MDB_FLAGS_OFFLOAD bit which indicates MDB entries is offloaded to hardware.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/uapi/linux/if_bridge.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index 18db144..ec35472 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -183,6 +183,8 @@ struct br_mdb_entry {
 #define MDB_TEMPORARY 0
 #define MDB_PERMANENT 1
 	__u8 state;
+#define MDB_FLAGS_OFFLOAD	(1 << 0)
+	__u8 flags;
 	__u16 vid;
 	struct {
 		union {
-- 
1.9.3
