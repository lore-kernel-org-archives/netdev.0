From: santosh nayak <santoshprasadnayak@gmail.com>
Subject: [PATCH] Driver: Atm:  Remove 'break' after 'return' statement.
Date: Tue,  3 Apr 2012 17:17:18 +0530
Message-ID: <1333453638-6235-1-git-send-email-santoshprasadnayak@gmail.com>
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Santosh Nayak <santoshprasadnayak@gmail.com>
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f52.google.com ([209.85.210.52]:54715 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248Ab2DCLtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 07:49:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Santosh Nayak <santoshprasadnayak@gmail.com>

'break' is unnecessary after 'return' statement.
Remove all such 'break' as clean up.

Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
---
 drivers/atm/horizon.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/atm/horizon.c b/drivers/atm/horizon.c
index b812103..71c801b 100644
--- a/drivers/atm/horizon.c
+++ b/drivers/atm/horizon.c
@@ -2183,7 +2183,6 @@ static int hrz_open (struct atm_vcc *atm_vcc)
     default:
       PRINTD (DBG_QOS|DBG_VCC, "Bad AAL!");
       return -EINVAL;
-      break;
   }
   
   // TX traffic parameters
@@ -2358,7 +2357,6 @@ static int hrz_open (struct atm_vcc *atm_vcc)
       default: {
 	PRINTD (DBG_QOS, "unsupported TX traffic class");
 	return -EINVAL;
-	break;
       }
     }
   }
@@ -2434,7 +2432,6 @@ static int hrz_open (struct atm_vcc *atm_vcc)
       default: {
 	PRINTD (DBG_QOS, "unsupported RX traffic class");
 	return -EINVAL;
-	break;
       }
     }
   }
@@ -2582,7 +2579,6 @@ static int hrz_getsockopt (struct atm_vcc * atm_vcc, int level, int optname,
 //	  break;
 	default:
 	  return -ENOPROTOOPT;
-	  break;
       };
       break;
   }
@@ -2602,7 +2598,6 @@ static int hrz_setsockopt (struct atm_vcc * atm_vcc, int level, int optname,
 //	  break;
 	default:
 	  return -ENOPROTOOPT;
-	  break;
       };
       break;
   }
-- 
1.7.4.4
