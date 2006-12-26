From: Keiichi KII <k-keiichi@bx.jp.nec.com>
Subject: [RFC][PATCH -mm take2 1/5] marking __init
Date: Tue, 26 Dec 2006 14:13:13 +0900
Message-ID: <4590AF69.2030300@bx.jp.nec.com>
References: <4590AE00.5040102@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:40418 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932235AbWLZFNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Dec 2006 00:13:21 -0500
To: mpm@selenic.com
In-Reply-To: <4590AE00.5040102@bx.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Keiichi KII <k-keiichi@bx.jp.nec.com>

This patch contains the following cleanups.
 - add __init for initialization functions(option_setup() and
   init_netconsole()).

Signed-off-by: Keiichi KII <k-keiichi@bx.jp.nec.com>
Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
---
--- linux-mm/drivers/net/netconsole.c	2006-12-26 14:10:17.177090000 +0900
+++ enhanced-netconsole/drivers/net/netconsole.c.cleanup	2006-12-25 16:44:31.615793750 +0900
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
Keiichi KII
NEC Corporation OSS Promotion Center
E-mail: k-keiichi@bx.jp.nec.com
