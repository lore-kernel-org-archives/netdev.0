From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 5/6] [INET_TIMEWAIT_SOCK]: Reorganize struct inet_timewait_sock to save some bytes
Date: Thu, 31 Jan 2008 16:31:43 -0200
Message-ID: <1201804304-28777-6-git-send-email-acme@redhat.com>
References: y
 <1201804304-28777-1-git-send-email-acme@redhat.com>
 <1201804304-28777-2-git-send-email-acme@redhat.com>
 <1201804304-28777-3-git-send-email-acme@redhat.com>
 <1201804304-28777-4-git-send-email-acme@redhat.com>
 <1201804304-28777-5-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.230]:28022 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763897AbYAaScm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:32:42 -0500
Received: by wr-out-0506.google.com with SMTP id c48so776441wra.23
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 10:32:42 -0800 (PST)
In-Reply-To: <1201804304-28777-5-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

/home/acme/git/net-2.6/net/ipv6/tcp_ipv6.c:
  struct inet_timewait_sock |   -8
  struct tcp_timewait_sock  |   -8
 2 structs changed
  tcp_v6_rcv                |   -6
 1 function changed, 6 bytes removed, diff: -6

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/net/inet_timewait_sock.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 67e9250..faead52 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -116,8 +116,8 @@ struct inet_timewait_sock {
 #define tw_hash			__tw_common.skc_hash
 #define tw_prot			__tw_common.skc_prot
 #define tw_net			__tw_common.skc_net
+	int			tw_timeout;
 	volatile unsigned char	tw_substate;
-	/* 3 bits hole, try to pack */
 	unsigned char		tw_rcv_wscale;
 	/* Socket demultiplex comparisons on incoming packets. */
 	/* these five are in inet_sock */
@@ -130,7 +130,6 @@ struct inet_timewait_sock {
 	__u8			tw_ipv6only:1;
 	/* 15 bits hole, try to pack */
 	__u16			tw_ipv6_offset;
-	int			tw_timeout;
 	unsigned long		tw_ttd;
 	struct inet_bind_bucket	*tw_tb;
 	struct hlist_node	tw_death_node;
-- 
1.5.3.8

