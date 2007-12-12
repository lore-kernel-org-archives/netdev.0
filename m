From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] Remove unused define from loopback driver
Date: Wed, 12 Dec 2007 17:44:54 +0300
Message-ID: <475FF3E6.9030507@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:42653 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750772AbXLLOpF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 09:45:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The LOOPBACK_OVERHEAD is not used in this file at all.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 662b8d1..3d1c743 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -64,8 +64,6 @@ struct pcpu_lstats {
 	unsigned long bytes;
 };
 
-#define LOOPBACK_OVERHEAD (128 + MAX_HEADER + 16 + 16)
-
 /* KISS: just allocate small chunks and copy bits.
  *
  * So, in fact, this is documentation, explaining what we expect
