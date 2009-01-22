From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH net-next-2.6] net: pppoe - get rid of DECLARE_MAC_BUF
Date: Thu, 22 Jan 2009 20:25:08 +0300
Message-ID: <20090122172508.GC20140@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NKML <netdev@vger.kernel.org>, Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:25968 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389AbZAVRZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 12:25:09 -0500
Received: by nf-out-0910.google.com with SMTP id d3so710250nfc.21
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2009 09:25:07 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While was playing with PPP namespaces I occasionally brought
back DECLARE_MAC_BUF which is not needed (we have %pM here).
Fix it.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 drivers/net/pppoe.c |    1 -
 1 file changed, 1 deletion(-)

Index: linux-2.6.git/drivers/net/pppoe.c
===================================================================
--- linux-2.6.git.orig/drivers/net/pppoe.c
+++ linux-2.6.git/drivers/net/pppoe.c
@@ -1004,7 +1004,6 @@ static int pppoe_seq_show(struct seq_fil
 {
 	struct pppox_sock *po;
 	char *dev_name;
-	DECLARE_MAC_BUF(mac);
 
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq, "Id       Address              Device\n");
