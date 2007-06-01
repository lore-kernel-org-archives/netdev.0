From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH] rfkill: Make rfkill->name const
Date: Fri, 1 Jun 2007 20:20:43 +0200
Message-ID: <200706012020.44112.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Torokhov <dtor@insightbb.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:50549 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760333AbXFASXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 14:23:42 -0400
Received: by ik-out-1112.google.com with SMTP id b32so595747ika
        for <netdev@vger.kernel.org>; Fri, 01 Jun 2007 11:23:40 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The rfkill name can be made const safely,
this makes the compiler happy when drivers make
it point to some const string used elsewhere.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

diff --git a/include/linux/rfkill.h b/include/linux/rfkill.h
index 7c1ffba..a8a6ea8 100644
--- a/include/linux/rfkill.h
+++ b/include/linux/rfkill.h
@@ -63,7 +63,7 @@ enum rfkill_state {
  * This structure represents a RF switch located on a network device.
  */
 struct rfkill {
-	char *name;
+	const char *name;
 	enum rfkill_type type;
 
 	enum rfkill_state state;
