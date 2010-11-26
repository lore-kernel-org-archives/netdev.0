From: frank.blaschka@de.ibm.com
Subject: [patch 2/4] [PATCH] drivers/s390/net: Remove unnecessary semicolons
Date: Fri, 26 Nov 2010 13:41:18 +0100
Message-ID: <20101126124154.105857044@de.ibm.com>
References: <20101126124116.123736494@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Joe Perches <joe@perches.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([194.196.100.163]:51228 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751335Ab0KZMmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 07:42:18 -0500
Content-Disposition: inline; filename=602-unnecessary-semicolons.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_sys.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/s390/net/qeth_core_sys.c
+++ b/drivers/s390/net/qeth_core_sys.c
@@ -372,7 +372,7 @@ static ssize_t qeth_dev_performance_stat
 	i = simple_strtoul(buf, &tmp, 16);
 	if ((i == 0) || (i == 1)) {
 		if (i == card->options.performance_stats)
-			goto out;;
+			goto out;
 		card->options.performance_stats = i;
 		if (i == 0)
 			memset(&card->perf_stats, 0,

