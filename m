From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 01/11] devlink: fix "devlink port" help message
Date: Fri, 15 Apr 2016 09:51:43 +0200
Message-ID: <1460706713-5942-2-git-send-email-jiri@resnulli.us>
References: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37766 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712AbcDOHv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 03:51:58 -0400
Received: by mail-wm0-f41.google.com with SMTP id n3so20196479wmn.0
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 00:51:57 -0700 (PDT)
In-Reply-To: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

"dl" -> "devlink"

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 devlink/devlink.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index c2da850..39f423a 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -578,9 +578,9 @@ static int cmd_dev(struct dl *dl)
 static void cmd_port_help(void)
 {
 	pr_out("Usage: devlink port show [ DEV/PORT_INDEX ]\n");
-	pr_out("       dl port set DEV/PORT_INDEX [ type { eth | ib | auto} ]\n");
-	pr_out("       dl port split DEV/PORT_INDEX count COUNT\n");
-	pr_out("       dl port unsplit DEV/PORT_INDEX\n");
+	pr_out("       devlink port set DEV/PORT_INDEX [ type { eth | ib | auto} ]\n");
+	pr_out("       devlink port split DEV/PORT_INDEX count COUNT\n");
+	pr_out("       devlink port unsplit DEV/PORT_INDEX\n");
 }
 
 static const char *port_type_name(uint32_t type)
-- 
2.5.5
