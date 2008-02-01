From: acme@ghostprotocols.net
Subject: [PATCH 3/5] [DCCP]: Reorganize struct dccp_sock to save 8 bytes
Date: Fri,  1 Feb 2008 20:23:34 -0200
Message-ID: <47a39bf1.0d87460a.50b8.fffffe14@mx.google.com>
References: y
 <1201904616-4944-1-git-send-email-y>
 <1201904616-4944-2-git-send-email-y>
 <1201904616-4944-3-git-send-email-y>
Cc: netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:61839 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419AbYBAWXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 17:23:49 -0500
Received: by wx-out-0506.google.com with SMTP id h31so1986034wxd.4
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2008 14:23:48 -0800 (PST)
In-Reply-To: <1201904616-4944-3-git-send-email-y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>

/home/acme/git/net-2.6/net/dccp/ipv6.c:
  struct dccp_sock  |   -8
  struct dccp6_sock |   -8
 2 structs changed

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 include/linux/dccp.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 484e45c..aa07370 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -525,6 +525,7 @@ struct dccp_sock {
 	__u64				dccps_gsr;
 	__u64				dccps_gar;
 	__be32				dccps_service;
+	__u32				dccps_mss_cache;
 	struct dccp_service_list	*dccps_service_list;
 	__u32				dccps_timestamp_echo;
 	__u32				dccps_timestamp_time;
@@ -533,7 +534,6 @@ struct dccp_sock {
 	__u16				dccps_pcslen;
 	__u16				dccps_pcrlen;
 	unsigned long			dccps_ndp_count;
-	__u32				dccps_mss_cache;
 	unsigned long			dccps_rate_last;
 	struct dccp_minisock		dccps_minisock;
 	struct dccp_ackvec		*dccps_hc_rx_ackvec;
-- 
1.5.3.8

