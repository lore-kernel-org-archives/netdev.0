From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: [PATCH] CXGB3: Replace kcalloc(1,...) with kmalloc() in cxgb3_offload.c.
Date: Sun, 8 Jul 2007 05:39:02 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0707080537360.7944@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:39952 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650AbXGHJlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2007 05:41:03 -0400
Received: from [192.168.1.102] (CPE0018396a01ee-CM001404e0fd78.cpe.net.cable.rogers.com [74.102.207.204])
	(authenticated bits=0)
	by rubicon.netdirect.ca (8.13.1/8.13.1) with ESMTP id l689enSQ019501
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 8 Jul 2007 05:40:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>

---

diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index ebcf35e..999bc41 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -1105,7 +1105,7 @@ int cxgb3_offload_activate(struct adapter *adapter)
 	struct mtutab mtutab;
 	unsigned int l2t_capacity;

-	t = kcalloc(1, sizeof(*t), GFP_KERNEL);
+	t = kcalloc(sizeof(*t), GFP_KERNEL);
 	if (!t)
 		return -ENOMEM;

-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
