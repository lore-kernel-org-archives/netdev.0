From: "Tobin C. Harding" <me@tobin.cc>
Subject: [PATCH 1/2] include: Fix checkpatch whitespace error and warning
Date: Sun, 12 Feb 2017 13:57:33 +1100
Message-ID: <1486868254-5386-2-git-send-email-me@tobin.cc>
References: <1486868254-5386-1-git-send-email-me@tobin.cc>
Cc: mawilcox@microsoft.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, "Tobin C. Harding" <me@tobin.cc>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486868254-5386-1-git-send-email-me@tobin.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes two trivial whitespace messages (ERROR/WARNING).
Fixes trailing whitespace ERROR and fixes space before tabs WARNING.

Signed-off-by: Tobin C. Harding <me@tobin.cc>
---
 include/linux/idr.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/idr.h b/include/linux/idr.h
index 3c01b89..4a8de2f 100644
--- a/include/linux/idr.h
+++ b/include/linux/idr.h
@@ -1,6 +1,6 @@
 /*
  * include/linux/idr.h
- * 
+ *
  * 2002-10-18  written by Jim Houston jim.houston@ccur.com
  *	Copyright (C) 2002 by Concurrent Computer Corporation
  *	Distributed under the GNU GPL license version 2.
@@ -183,7 +183,7 @@ static inline void *idr_find(struct idr *idr, int id)
  */
 #define IDA_CHUNK_SIZE		128	/* 128 bytes per chunk */
 #define IDA_BITMAP_LONGS	(IDA_CHUNK_SIZE / sizeof(long) - 1)
-#define IDA_BITMAP_BITS 	(IDA_BITMAP_LONGS * sizeof(long) * 8)
+#define IDA_BITMAP_BITS         (IDA_BITMAP_LONGS * sizeof(long) * 8)
 
 struct ida_bitmap {
 	long			nr_busy;
-- 
2.7.4
