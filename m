From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH] qla3xxx: bugfix for line omitted in previous patch.
Date: Wed, 28 Feb 2007 16:48:26 -0800
Message-ID: <20070301004826.GA32624@linux-7mw0.qlogic.org>
References: <20070226190450.GA7325@linux-7mw0.qlogic.org> <11725168032993-git-send-email-ron.mercer@qlogic.com> <45E3F83F.6010003@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	benjamin.li@qlogic.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:8941 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932841AbXCAAs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Feb 2007 19:48:29 -0500
Content-Disposition: inline
In-Reply-To: <45E3F83F.6010003@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>From 01751a39d7327acc28dabf4f68930b7e20b279d1 Mon Sep 17 00:00:00 2001
From: Ron Mercer <ron.mercer@qlogic.com>
Date: Wed, 28 Feb 2007 16:42:17 -0800
Subject: [PATCH] [PATCH] qla3xxx: bugfix for line omitted in previous patch.

This missing line caused transmit errors on the Qlogic 4032 chip.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 3a14d19..d3f65da 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2210,7 +2210,7 @@ static int ql_send_map(struct ql3_adapter *qdev,
 {
 	struct oal *oal;
 	struct oal_entry *oal_entry;
-	int len = skb->len;
+	int len = skb_headlen(skb);
 	dma_addr_t map;
 	int err;
 	int completed_segs, i;
-- 
1.5.0.rc4.16.g9e258

