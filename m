From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 04/43] drivers/net/ns83820.c: fix sparse warnings: fix
	signedness
Date: Sat, 14 Feb 2009 22:12:36 +0100
Message-ID: <20090214211231.23489.52423.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:39192 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbZBNVMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:12:40 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:
  drivers/net/ns83820.c:479:36: warning: incorrect type in argument 2 (different signedness)
  drivers/net/ns83820.c:479:36: warning: incorrect type in argument 2 (different signedness)
  drivers/net/ns83820.c:479:36: warning: incorrect type in argument 2 (different signedness)
  drivers/net/ns83820.c:479:36: warning: incorrect type in argument 2 (different signedness)

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/ns83820.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index e80294d..9266502 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -409,7 +409,7 @@ static int lnksts = 0;		/* CFG_LNKSTS bit polarity */
 struct rx_info {
 	spinlock_t	lock;
 	int		up;
-	long		idle;
+	unsigned long	idle;
 
 	struct sk_buff	*skbs[NR_RX_DESC];
 

