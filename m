From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: [PATCH] ehea: Remove a silly return
Date: Thu, 16 Sep 2010 00:54:22 -0300
Message-ID: <1284609262-8653-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: Breno Leitao <leitao@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:58634 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752731Ab0IPDzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 23:55:01 -0400
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp04.br.ibm.com (8.14.4/8.13.1) with ESMTP id o8G3oM70028940
	for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 00:50:22 -0300
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.8.31.93])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8G40niv835660
	for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 01:00:50 -0300
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8G3shEv014350
	for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 00:54:43 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the unconditional return in the end of the
function check_sqs()

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/ehea/ehea_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index a333b42..d77015b 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -818,8 +818,6 @@ static void check_sqs(struct ehea_port *port)
 			}
 		}
 	}
-
-	return;
 }
 
 
-- 
1.7.2.2

