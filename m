From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Subject: [PATCH]bnx2x: remove duplication of the BCM_VLAN macro
Date: Thu, 22 Oct 2009 00:38:51 +0400
Message-ID: <20091021203851.GA5311@coldcone>
Reply-To: kirjanov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:37568 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753616AbZJUUg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 16:36:58 -0400
Received: by fxm18 with SMTP id 18so8224897fxm.37
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 13:37:01 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

File bnx2.c already contains condition of the macro inclusion.
So we can remove this.

Signed-off-by: Denis Kirjanov <kirjanov@gmail.com>
---

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index bbf8422..4b99fd2 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -20,10 +20,6 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-#define BCM_VLAN			1
-#endif
-
 
 #define BNX2X_MULTI_QUEUE
 
