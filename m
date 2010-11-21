From: Joe Perches <joe@perches.com>
Subject: [PATCH 24/62] irda: Use static const
Date: Sat, 20 Nov 2010 18:38:25 -0800
Message-ID: <ac16f4e303235f7f2b464b3fc8f5f002eb7e06aa.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1670 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756501Ab0KUCkE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Nov 2010 21:40:04 -0500
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
   1540	    100	    320	   1960	    7a8	drivers/net/irda/act200l-sir.o.new
   1597	    100	    320	   2017	    7e1	drivers/net/irda/act200l-sir.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/irda/act200l-sir.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/irda/act200l-sir.c b/drivers/net/irda/act200l-sir.c
index 37ab8c8..8ff084f 100644
--- a/drivers/net/irda/act200l-sir.c
+++ b/drivers/net/irda/act200l-sir.c
@@ -199,7 +199,7 @@ static int act200l_reset(struct sir_dev *dev)
 {
 	unsigned state = dev->fsm.substate;
 	unsigned delay = 0;
-	u8 control[9] = {
+	static const u8 control[9] = {
 		ACT200L_REG15,
 		ACT200L_REG13 | ACT200L_SHDW,
 		ACT200L_REG21 | ACT200L_EXCK | ACT200L_OSCL,
-- 
1.7.3.2.245.g03276.dirty

