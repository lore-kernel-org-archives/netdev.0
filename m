From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] netfilter: allow nf_tproxy_core module to be
 removed
Date: Wed, 23 Jun 2010 20:35:04 +0200
Message-ID: <20100623183503.GE2687@psychotron.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27601 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752860Ab0FWSfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jun 2010 14:35:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/net/netfilter/nf_tproxy_core.c b/net/netfilter/nf_tproxy_core.c
index 5490fc3..ec6737c 100644
--- a/net/netfilter/nf_tproxy_core.c
+++ b/net/netfilter/nf_tproxy_core.c
@@ -89,7 +89,12 @@ static int __init nf_tproxy_init(void)
 	return 0;
 }
 
+static void __exit nf_tproxy_exit(void)
+{
+}
+
 module_init(nf_tproxy_init);
+module_exit(nf_tproxy_exit);
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Krisztian Kovacs");
