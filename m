From: jamal <hadi@cyberus.ca>
Subject: [PKT_SCHED]: Return ENOENT if qdisc module is unavailable
Date: Thu, 06 Jul 2006 08:40:17 -0400
Message-ID: <1152189617.5103.25.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-m/l5quBsf+IPECcNw3tN"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:45242 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S965025AbWGFMkU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jul 2006 08:40:20 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FyT9a-0007WH-IV
	for netdev@vger.kernel.org; Thu, 06 Jul 2006 08:40:22 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-m/l5quBsf+IPECcNw3tN
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


And this is similar to Thomas' patch 2/3 that i pointed out in the
email.
It is not intended for stable, so a latter -rc or even 2.6.18

cheers,
jamal

--=-m/l5quBsf+IPECcNw3tN
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
 

--=-m/l5quBsf+IPECcNw3tN--

