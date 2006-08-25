From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] Congestion control (modulo lp, bic): use BUILD_BUG_ON
Date: Sat, 26 Aug 2006 03:57:41 +0400
Message-ID: <20060825235741.GD2246@martell.zuzino.mipt.ru>
References: <20060825010802.GK5204@martell.zuzino.mipt.ru> <20060825162720.3d4257d7@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:4298 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932102AbWHYX5q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 19:57:46 -0400
Received: by nf-out-0910.google.com with SMTP id o25so909032nfa
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2006 16:57:45 -0700 (PDT)
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060825162720.3d4257d7@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/tcp_cubic.c     |    2 +-
 net/ipv4/tcp_highspeed.c |    2 +-
 net/ipv4/tcp_htcp.c      |    2 +-
 net/ipv4/tcp_hybla.c     |    2 +-
 net/ipv4/tcp_vegas.c     |    2 +-
 net/ipv4/tcp_veno.c      |    2 +-
 net/ipv4/tcp_westwood.c  |    2 +-
 7 files changed, 7 insertions(+), 7 deletions(-)

--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -358,7 +358,7 @@ static struct tcp_congestion_ops cubictc
 
 static int __init cubictcp_register(void)
 {
-	BUG_ON(sizeof(struct bictcp) > ICSK_CA_PRIV_SIZE);
+	BUILD_BUG_ON(sizeof(struct bictcp) > ICSK_CA_PRIV_SIZE);
 
 	/* Precompute a bunch of the scaling factors that are used per-packet
 	 * based on SRTT of 100ms
--- a/net/ipv4/tcp_highspeed.c
+++ b/net/ipv4/tcp_highspeed.c
@@ -189,7 +189,7 @@ static struct tcp_congestion_ops tcp_hig
 
 static int __init hstcp_register(void)
 {
-	BUG_ON(sizeof(struct hstcp) > ICSK_CA_PRIV_SIZE);
+	BUILD_BUG_ON(sizeof(struct hstcp) > ICSK_CA_PRIV_SIZE);
 	return tcp_register_congestion_control(&tcp_highspeed);
 }
 
--- a/net/ipv4/tcp_htcp.c
+++ b/net/ipv4/tcp_htcp.c
@@ -286,7 +286,7 @@ static struct tcp_congestion_ops htcp = 
 
 static int __init htcp_register(void)
 {
-	BUG_ON(sizeof(struct htcp) > ICSK_CA_PRIV_SIZE);
+	BUILD_BUG_ON(sizeof(struct htcp) > ICSK_CA_PRIV_SIZE);
 	BUILD_BUG_ON(BETA_MIN >= BETA_MAX);
 	return tcp_register_congestion_control(&htcp);
 }
--- a/net/ipv4/tcp_hybla.c
+++ b/net/ipv4/tcp_hybla.c
@@ -170,7 +170,7 @@ static struct tcp_congestion_ops tcp_hyb
 
 static int __init hybla_register(void)
 {
-	BUG_ON(sizeof(struct hybla) > ICSK_CA_PRIV_SIZE);
+	BUILD_BUG_ON(sizeof(struct hybla) > ICSK_CA_PRIV_SIZE);
 	return tcp_register_congestion_control(&tcp_hybla);
 }
 
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -370,7 +370,7 @@ static struct tcp_congestion_ops tcp_veg
 
 static int __init tcp_vegas_register(void)
 {
-	BUG_ON(sizeof(struct vegas) > ICSK_CA_PRIV_SIZE);
+	BUILD_BUG_ON(sizeof(struct vegas) > ICSK_CA_PRIV_SIZE);
 	tcp_register_congestion_control(&tcp_vegas);
 	return 0;
 }
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -213,7 +213,7 @@ static struct tcp_congestion_ops tcp_ven
 
 static int __init tcp_veno_register(void)
 {
-	BUG_ON(sizeof(struct veno) > ICSK_CA_PRIV_SIZE);
+	BUILD_BUG_ON(sizeof(struct veno) > ICSK_CA_PRIV_SIZE);
 	tcp_register_congestion_control(&tcp_veno);
 	return 0;
 }
--- a/net/ipv4/tcp_westwood.c
+++ b/net/ipv4/tcp_westwood.c
@@ -289,7 +289,7 @@ static struct tcp_congestion_ops tcp_wes
 
 static int __init tcp_westwood_register(void)
 {
-	BUG_ON(sizeof(struct westwood) > ICSK_CA_PRIV_SIZE);
+	BUILD_BUG_ON(sizeof(struct westwood) > ICSK_CA_PRIV_SIZE);
 	return tcp_register_congestion_control(&tcp_westwood);
 }
 

