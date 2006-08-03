From: jamal <hadi@cyberus.ca>
Subject: Resend [PKT_SCHED]: Return ENOENT if qdisc module is unavailable
Date: Thu, 03 Aug 2006 09:20:10 -0400
Message-ID: <1154611210.5205.43.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-l6Z54Vv0EdAFyuXOGtUo"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:20458 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932534AbWHCOl4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 10:41:56 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1G8eOP-0003Gj-1E
	for netdev@vger.kernel.org; Thu, 03 Aug 2006 10:41:45 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-l6Z54Vv0EdAFyuXOGtUo
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Dave,

Old patch - didnt see it reflected in this mornings sync with linus tree
and dont wanna loose it (git is great at reminding me); if queued
already, just ignore. 

cheers,
jamal

--=-l6Z54Vv0EdAFyuXOGtUo
Content-Disposition: attachment; filename=sch-ne
Content-Type: text/plain; name=sch-ne; charset=UTF-8
Content-Transfer-Encoding: 7bit


Return ENOENT if qdisc module is unavailable

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 31570b9..44724c6 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -431,7 +431,7 @@ #ifdef CONFIG_KMOD
 	}
 #endif
 
-	err = -EINVAL;
+	err = -ENOENT;
 	if (ops == NULL)
 		goto err_out;
 

--=-l6Z54Vv0EdAFyuXOGtUo--

