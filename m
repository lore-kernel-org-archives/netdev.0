From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 01/27] drivers/net: fix sparse warning: use ANSI-style
	function declaration
Date: Mon, 22 Dec 2008 20:14:58 +0100
Message-ID: <20081222191458.11807.57800.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:50184 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754455AbYLVTPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:15:05 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warning:

  drivers/net/ne.c:932:24: warning: non-ANSI function declaration of function 'init_module'

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/ne.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index cb02698..5c3e242 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -929,7 +929,7 @@ static void __init ne_add_devices(void)
 }
 
 #ifdef MODULE
-int __init init_module()
+int __init init_module(void)
 {
 	int retval;
 	ne_add_devices();

