From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] irlan: fix header build warning
Date: Wed, 6 Dec 2006 11:44:07 -0800
Message-ID: <20061206114407.9b835a7a.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:39609 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937558AbWLFTn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 14:43:28 -0500
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix compile warning when CONFIG_PROC_FS=n:

include/net/irda/irlan_filter.h:31: warning: 'struct seq_file' declared inside parameter list
include/net/irda/irlan_filter.h:31: warning: its scope is only this definition or declaration, which is probably not what you want

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/net/irda/irlan_filter.h |    1 +
 1 file changed, 1 insertion(+)

--- linux-2.6.19-git7.orig/include/net/irda/irlan_filter.h
+++ linux-2.6.19-git7/include/net/irda/irlan_filter.h
@@ -28,6 +28,7 @@
 void irlan_check_command_param(struct irlan_cb *self, char *param, 
 			       char *value);
 void irlan_filter_request(struct irlan_cb *self, struct sk_buff *skb);
+struct seq_file;
 void irlan_print_filter(struct seq_file *seq, int filter_type);
 
 #endif /* IRLAN_FILTER_H */


---
