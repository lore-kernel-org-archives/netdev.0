From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/5] afkey: add sparse annotation about rcu
Date: Wed, 23 Feb 2011 11:06:50 -0800
Message-ID: <20110223190701.055229602@vyatta.com>
References: <20110223190647.482444598@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:44644 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753617Ab1BWTxB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 14:53:01 -0500
Content-Disposition: inline; filename=afkey-sparse
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/key/af_key.c	2011-02-23 10:20:23.181943425 -0800
+++ b/net/key/af_key.c	2011-02-23 10:20:47.290221581 -0800
@@ -3655,6 +3655,7 @@ static int pfkey_seq_show(struct seq_fil
 }
 
 static void *pfkey_seq_start(struct seq_file *f, loff_t *ppos)
+	__acquires(rcu)
 {
 	struct net *net = seq_file_net(f);
 	struct netns_pfkey *net_pfkey = net_generic(net, pfkey_net_id);
@@ -3672,6 +3673,7 @@ static void *pfkey_seq_next(struct seq_f
 }
 
 static void pfkey_seq_stop(struct seq_file *f, void *v)
+	__releases(rcu)
 {
 	rcu_read_unlock();
 }


