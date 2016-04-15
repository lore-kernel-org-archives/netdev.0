From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 03/11] list: add list_add_tail helper
Date: Fri, 15 Apr 2016 09:51:45 +0200
Message-ID: <1460706713-5942-4-git-send-email-jiri@resnulli.us>
References: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35884 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407AbcDOHwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 03:52:00 -0400
Received: by mail-wm0-f49.google.com with SMTP id v188so19288131wme.1
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 00:52:00 -0700 (PDT)
In-Reply-To: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/list.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/list.h b/include/list.h
index b549c3e..5b529dc 100644
--- a/include/list.h
+++ b/include/list.h
@@ -33,6 +33,11 @@ static inline void list_add(struct list_head *new, struct list_head *head)
 	__list_add(new, head, head->next);
 }
 
+static inline void list_add_tail(struct list_head *new, struct list_head *head)
+{
+	__list_add(new, head->prev, head);
+}
+
 static inline void __list_del(struct list_head *prev, struct list_head *next)
 {
 	next->prev = prev;
-- 
2.5.5
