From: acme@ghostprotocols.net
Subject: [PATCH 4/5] [INET_TIMEWAIT_SOCK]: Reorganize struct inet_timewait_sock to save some bytes
Date: Fri,  1 Feb 2008 20:23:35 -0200
Message-ID: <47a39bf9.2586460a.73d1.68c0@mx.google.com>
References: y
 <1201904616-4944-1-git-send-email-y>
 <1201904616-4944-2-git-send-email-y>
 <1201904616-4944-3-git-send-email-y>
 <1201904616-4944-4-git-send-email-y>
Cc: netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:61339 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754884AbYBAWX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 17:23:57 -0500
Received: by wx-out-0506.google.com with SMTP id h31so1986032wxd.4
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2008 14:23:57 -0800 (PST)
In-Reply-To: <1201904616-4944-4-git-send-email-y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>

/home/acme/git/net-2.6/net/ipv6/tcp_ipv6.c:
  struct inet_timewait_sock |   -8
  struct tcp_timewait_sock  |   -8
 2 structs changed
  tcp_v6_rcv                |   -6
 1 function changed, 6 bytes removed, diff: -6

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/net/inet_timewait_sock.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 67e9250..296547b 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -116,6 +116,7 @@ struct inet_timewait_sock {
 #define tw_hash			__tw_common.skc_hash
 #define tw_prot			__tw_common.skc_prot
 #define tw_net			__tw_common.skc_net
+	int			tw_timeout;
 	volatile unsigned char	tw_substate;
 	/* 3 bits hole, try to pack */
 	unsigned char		tw_rcv_wscale;
@@ -130,7 +131,6 @@ struct inet_timewait_sock {
 	__u8			tw_ipv6only:1;
 	/* 15 bits hole, try to pack */
 	__u16			tw_ipv6_offset;
-	int			tw_timeout;
 	unsigned long		tw_ttd;
 	struct inet_bind_bucket	*tw_tb;
 	struct hlist_node	tw_death_node;
-- 
1.5.3.8

