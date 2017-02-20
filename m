From: Ivan Vecera <cera@cera.cz>
Subject: [PATCH ethtool] ethtool: sync help output for -x/-X with man page
Date: Mon, 20 Feb 2017 15:13:52 +0100
Message-ID: <20170220141352.9329-1-cera@cera.cz>
Cc: linville@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35928 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753273AbdBTONz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 09:13:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing words to the help output for -x and -X commands as well
as an ability to set the indirection table to default value.

Signed-off-by: Ivan Vecera <cera@cera.cz>
---
 ethtool.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 7af039e..61043ee 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -4786,10 +4786,10 @@ static const struct option {
 	{ "-T|--show-time-stamping", 1, do_tsinfo,
 	  "Show time stamping capabilities" },
 	{ "-x|--show-rxfh-indir|--show-rxfh", 1, do_grxfh,
-	  "Show Rx flow hash indirection and/or hash key" },
+	  "Show Rx flow hash indirection table and/or RSS hash key" },
 	{ "-X|--set-rxfh-indir|--rxfh", 1, do_srxfh,
-	  "Set Rx flow hash indirection and/or hash key",
-	  "		[ equal N | weight W0 W1 ... ]\n"
+	  "Set Rx flow hash indirection table and/or RSS hash key",
+	  "		[ equal N | weight W0 W1 ... | default ]\n"
 	  "		[ hkey %x:%x:%x:%x:%x:.... ]\n" },
 	{ "-f|--flash", 1, do_flash,
 	  "Flash firmware image from the specified file to a region on the device",
-- 
2.10.2
