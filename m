From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 22/43] drivers/net/hamradio: fix sparse warnings: fix
	signedness
Date: Sat, 14 Feb 2009 22:36:20 +0100
Message-ID: <20090214213543.24377.50515.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:43060 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145AbZBNVg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:36:26 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:
  drivers/net/hamradio/hdlcdrv.c:274:34: warning: incorrect type in argument 2 (different signedness)
  drivers/net/hamradio/hdlcdrv.c:279:47: warning: incorrect type in argument 2 (different signedness)
  drivers/net/hamradio/hdlcdrv.c:288:39: warning: incorrect type in argument 2 (different signedness)
  drivers/net/hamradio/hdlcdrv.c:300:47: warning: incorrect type in argument 2 (different signedness)

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 include/linux/hdlcdrv.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/hdlcdrv.h b/include/linux/hdlcdrv.h
index 0821bac..c010b4a 100644
--- a/include/linux/hdlcdrv.h
+++ b/include/linux/hdlcdrv.h
@@ -215,7 +215,7 @@ struct hdlcdrv_state {
 
 	struct hdlcdrv_hdlctx {
 		struct hdlcdrv_hdlcbuffer hbuf;
-		long in_hdlc_tx;
+		unsigned long in_hdlc_tx;
 		/*
 		 * 0 = send flags
 		 * 1 = send txtail (flags)

