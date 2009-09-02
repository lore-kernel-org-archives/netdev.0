From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/5] net: seq_operations should be const
Date: Tue, 01 Sep 2009 22:25:02 -0700
Message-ID: <20090902052538.353868084@vyatta.com>
References: <20090902052500.808557262@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:46825 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755809AbZIBFhG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 01:37:06 -0400
Content-Disposition: inline; filename=const-seq-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/ipv6/ip6mr.c |    2 +-
 net/key/af_key.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- a/net/ipv6/ip6mr.c	2009-09-01 21:37:24.504215187 -0700
+++ b/net/ipv6/ip6mr.c	2009-09-01 22:22:22.223174601 -0700
@@ -204,7 +204,7 @@ static int ip6mr_vif_seq_show(struct seq
 	return 0;
 }
 
-static struct seq_operations ip6mr_vif_seq_ops = {
+static const struct seq_operations ip6mr_vif_seq_ops = {
 	.start = ip6mr_vif_seq_start,
 	.next  = ip6mr_vif_seq_next,
 	.stop  = ip6mr_vif_seq_stop,
--- a/net/key/af_key.c	2009-09-01 21:37:24.520180026 -0700
+++ b/net/key/af_key.c	2009-09-01 22:22:22.230177877 -0700
@@ -3705,7 +3705,7 @@ static void pfkey_seq_stop(struct seq_fi
 	read_unlock(&pfkey_table_lock);
 }
 
-static struct seq_operations pfkey_seq_ops = {
+static const struct seq_operations pfkey_seq_ops = {
 	.start	= pfkey_seq_start,
 	.next	= pfkey_seq_next,
 	.stop	= pfkey_seq_stop,

-- 

