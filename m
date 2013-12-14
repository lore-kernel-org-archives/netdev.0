From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] bnad: make local variable static
Date: Fri, 13 Dec 2013 16:40:10 -0800
Message-ID: <20131213164010.0d082bbe@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rasesh Mody <rmody@brocade.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:56102 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752378Ab3LNAkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 19:40:14 -0500
Received: by mail-pb0-f47.google.com with SMTP id um1so3245871pbc.20
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 16:40:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile tested only.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/ethernet/brocade/bna/bnad.c	2013-12-12 11:48:17.033855594 -0800
+++ b/drivers/net/ethernet/brocade/bna/bnad.c	2013-12-12 11:56:57.325752730 -0800
@@ -52,7 +52,7 @@ MODULE_PARM_DESC(bna_debugfs_enable, "En
 /*
  * Global variables
  */
-u32 bnad_rxqs_per_cq = 2;
+static u32 bnad_rxqs_per_cq = 2;
 static u32 bna_id;
 static struct mutex bnad_list_mutex;
 static LIST_HEAD(bnad_list);
--- a/drivers/net/ethernet/brocade/bna/bnad.h	2013-12-12 11:48:17.033855594 -0800
+++ b/drivers/net/ethernet/brocade/bna/bnad.h	2013-12-12 11:56:57.325752730 -0800
@@ -367,7 +367,6 @@ struct bnad_drvinfo {
  * EXTERN VARIABLES
  */
 extern const struct firmware *bfi_fw;
-extern u32		bnad_rxqs_per_cq;
 
 /*
  * EXTERN PROTOTYPES
