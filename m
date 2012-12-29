From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH]  tcp: make proc_tcp_fastopen_key static
Date: Fri, 28 Dec 2012 20:20:24 -0800
Message-ID: <20121228202024.2d3dea76@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51790 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016Ab2L2EVq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2012 23:21:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Detected by sparse.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/sysctl_net_ipv4.c	2012-11-30 10:29:10.903478045 -0800
+++ b/net/ipv4/sysctl_net_ipv4.c	2012-12-28 20:05:49.687988892 -0800
@@ -232,8 +232,8 @@ static int ipv4_tcp_mem(ctl_table *ctl,
 	return 0;
 }
 
-int proc_tcp_fastopen_key(ctl_table *ctl, int write, void __user *buffer,
-			  size_t *lenp, loff_t *ppos)
+static int proc_tcp_fastopen_key(ctl_table *ctl, int write, void __user *buffer,
+				 size_t *lenp, loff_t *ppos)
 {
 	ctl_table tbl = { .maxlen = (TCP_FASTOPEN_KEY_LENGTH * 2 + 10) };
 	struct tcp_fastopen_context *ctxt;
