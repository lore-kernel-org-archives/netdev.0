From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: Add missing break to TCP option parsing code
Date: Thu, 14 Jun 2007 12:37:22 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0706141235470.15358@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1129429435-1181813842=:15358"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34580 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbXFNJhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2007 05:37:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1129429435-1181813842=:15358
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

This flaw does not affect any behavior (currently).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d506bdc..aaf6f66 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2936,6 +2936,7 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 					   opt_rx->sack_ok) {
 						TCP_SKB_CB(skb)->sacked = (ptr - 2) - (unsigned char *)th;
 					}
+					break;
 #ifdef CONFIG_TCP_MD5SIG
 				case TCPOPT_MD5SIG:
 					/*
-- 
1.5.0.6

---696243703-1129429435-1181813842=:15358--
