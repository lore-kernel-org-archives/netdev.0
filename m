From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/2] dccp: make local variable static
Date: Sat, 4 Jan 2014 13:46:29 -0800
Message-ID: <20140104134629.6658ab1c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:37167 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753656AbaADVqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 16:46:32 -0500
Received: by mail-pd0-f179.google.com with SMTP id r10so16693068pdi.38
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 13:46:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make DCCP module config variable static, only used in one file.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 net/dccp/ccids/lib/tfrc.c |    2 +-
 net/dccp/ccids/lib/tfrc.h |    1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

--- a/net/dccp/ccids/lib/tfrc.c	2014-01-04 13:39:54.476218461 -0800
+++ b/net/dccp/ccids/lib/tfrc.c	2014-01-04 13:42:22.249773638 -0800
@@ -8,7 +8,7 @@
 #include "tfrc.h"
 
 #ifdef CONFIG_IP_DCCP_TFRC_DEBUG
-bool tfrc_debug;
+static bool tfrc_debug;
 module_param(tfrc_debug, bool, 0644);
 MODULE_PARM_DESC(tfrc_debug, "Enable TFRC debug messages");
 #endif
--- a/net/dccp/ccids/lib/tfrc.h	2014-01-04 13:39:54.476218461 -0800
+++ b/net/dccp/ccids/lib/tfrc.h	2014-01-04 13:42:22.249773638 -0800
@@ -21,7 +21,6 @@
 #include "packet_history.h"
 
 #ifdef CONFIG_IP_DCCP_TFRC_DEBUG
-extern bool tfrc_debug;
 #define tfrc_pr_debug(format, a...)	DCCP_PR_DEBUG(tfrc_debug, format, ##a)
 #else
 #define tfrc_pr_debug(format, a...)
