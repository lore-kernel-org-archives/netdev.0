From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH] rfkill: Make state sysfs writable
Date: Wed, 18 Jul 2007 19:59:22 +0200
Message-ID: <200707181959.22520.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dmitry Torokhov <dtor@insightbb.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:17728 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762361AbXGRR5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 13:57:45 -0400
Received: by ug-out-1314.google.com with SMTP id j3so294413ugf
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2007 10:57:43 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The rfkill state Sysfs attribute should be made writable,
we already pass the argument for the store handler,
so we only need to update the permissions flag.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

---

diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
index f3986d4..db3395b 100644
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -187,7 +187,7 @@ static ssize_t rfkill_claim_store(struct device *dev,
 static struct device_attribute rfkill_dev_attrs[] = {
 	__ATTR(name, S_IRUGO, rfkill_name_show, NULL),
 	__ATTR(type, S_IRUGO, rfkill_type_show, NULL),
-	__ATTR(state, S_IRUGO, rfkill_state_show, rfkill_state_store),
+	__ATTR(state, S_IRUGO|S_IWUSR, rfkill_state_show, rfkill_state_store),
 	__ATTR(claim, S_IRUGO|S_IWUSR, rfkill_claim_show, rfkill_claim_store),
 	__ATTR_NULL
 };
