From: frank.blaschka@de.ibm.com
Subject: [patch 1/3] qeth: use -EOPNOTSUPP instead of -ENOTSUPP.
Date: Fri, 15 Aug 2008 08:02:58 +0200
Message-ID: <20080815060351.630030000@de.ibm.com>
References: <20080815060257.501264000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:39802 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbYHOGDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 02:03:54 -0400
Content-Disposition: inline; filename=600-qeth-rc.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

return value -ENOTSUPP is not valid in userspace context, use
-EOPNOTSUPP instead.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l3_sys.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_l3_sys.c linux-2.6-patched/drivers/s390/net/qeth_l3_sys.c
--- linux-2.6/drivers/s390/net/qeth_l3_sys.c	2008-07-13 23:51:29.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_sys.c	2008-08-14 18:46:41.000000000 +0200
@@ -136,7 +136,7 @@ static ssize_t qeth_l3_dev_route6_store(
 		return -EINVAL;
 
 	if (!qeth_is_supported(card, IPA_IPV6)) {
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 	}
 
 	return qeth_l3_dev_route_store(card, &card->options.route6,

-- 
