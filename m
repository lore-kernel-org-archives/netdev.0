From: Nogah Frankel <nogahf@mellanox.com>
Subject: [PATCH iproute2 v5 1/4] ifstat: Includes reorder
Date: Thu, 26 Jan 2017 14:44:38 +0200
Message-ID: <1485434681-33947-2-git-send-email-nogahf@mellanox.com>
References: <1485434681-33947-1-git-send-email-nogahf@mellanox.com>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
        roszenrami@gmail.com, jbenc@redhat.com,
        sergei.shtylyov@cogentembedded.com, jiri@mellanox.com,
        eladr@mellanox.com, idosch@mellanox.com, yotamg@mellanox.com,
        ogerlitz@mellanox.com, Nogah Frankel <nogahf@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51765 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752020AbdAZMnG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 07:43:06 -0500
In-Reply-To: <1485434681-33947-1-git-send-email-nogahf@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reorder the includes in misc/ifstat.c to match convention.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 misc/ifstat.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/misc/ifstat.c b/misc/ifstat.c
index 92d67b0..5bcbcc8 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -28,12 +28,12 @@
 #include <math.h>
 #include <getopt.h>
 
-#include <libnetlink.h>
-#include <json_writer.h>
 #include <linux/if.h>
 #include <linux/if_link.h>
 
-#include <SNAPSHOT.h>
+#include "libnetlink.h"
+#include "json_writer.h"
+#include "SNAPSHOT.h"
 
 int dump_zeros;
 int reset_history;
-- 
2.4.3
