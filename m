From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: [RFC][PATCH -mm take5 1/7] marking __init
Date: Wed, 13 Jun 2007 19:25:55 +0900
Message-ID: <466FC633.1040404@bx.jp.nec.com>
References: <466FC455.5060001@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:55567 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755921AbXFMK0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 06:26:25 -0400
In-Reply-To: <466FC455.5060001@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Keiichi KII <k-keiichi@bx.jp.nec.com>

This patch contains the following cleanups.
 - add __init for initialization functions(option_setup() and
   init_netconsole()).

Acked-by: Matt Mackall <mpm@selenic.com>
Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>
Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
---
Index: linux-mm/drivers/net/netconsole.c
===================================================================
--- linux-mm.orig/drivers/net/netconsole.c
+++ linux-mm/drivers/net/netconsole.c
@@ -91,7 +91,7 @@ static struct console netconsole = {
 	.write = write_msg
 };
 
-static int option_setup(char *opt)
+static int __init option_setup(char *opt)
 {
 	configured = !netpoll_parse_options(&np, opt);
 	return 1;
@@ -99,7 +99,7 @@ static int option_setup(char *opt)
 
 __setup("netconsole=", option_setup);
 
-static int init_netconsole(void)
+static int __init init_netconsole(void)
 {
 	int err;
 

-- 



