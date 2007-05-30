From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/3] myri10ge: report link up/down in standard ethtool way
Date: Wed, 30 May 2007 21:13:59 +0200
Message-ID: <465DCCF7.9050408@myri.com>
References: <465DCCB4.5040404@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:2022 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751733AbXE3TNq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 15:13:46 -0400
In-Reply-To: <465DCCB4.5040404@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Report link up/down in standard ethtool way

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-05-26 11:18:09.000000000 +0200
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-05-30 20:58:22.000000000 +0200
@@ -1472,6 +1472,7 @@
 	.set_sg = ethtool_op_set_sg,
 	.get_tso = ethtool_op_get_tso,
 	.set_tso = ethtool_op_set_tso,
+	.get_link = ethtool_op_get_link,
 	.get_strings = myri10ge_get_strings,
 	.get_stats_count = myri10ge_get_stats_count,
 	.get_ethtool_stats = myri10ge_get_ethtool_stats,


