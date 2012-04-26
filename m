From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] IPVS: ip_vs_ftp.c: local functions should not be exposed globally
Date: Thu, 26 Apr 2012 11:17:28 -0700
Message-ID: <201204261117.28491.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail131.messagelabs.com ([216.82.242.99]:56792 "EHLO
	mail131.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757030Ab2DZSRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 14:17:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Functions not referenced outside of a source file should be marked
static to prevent it from being exposed globally.

This quiets the sparse warnings:

warning: symbol 'ip_vs_ftp_init' was not declared. Should it be static?

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: "David S. Miller" <davem@davemloft.net>

---

diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
index debb8c7..091bec9 100644
--- a/net/netfilter/ipvs/ip_vs_ftp.c
+++ b/net/netfilter/ipvs/ip_vs_ftp.c
@@ -483,7 +483,7 @@ static struct pernet_operations ip_vs_ftp_ops = {
 	.exit = __ip_vs_ftp_exit,
 };
 
-int __init ip_vs_ftp_init(void)
+static int __init ip_vs_ftp_init(void)
 {
 	int rv;
 
