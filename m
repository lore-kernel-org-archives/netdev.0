From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH] drivers/isdn/hardware/mISDN: change type of hfc_jiffies to
	ulong
Date: Sat, 14 Feb 2009 23:44:21 +0100
Message-ID: <20090214224049.28194.38982.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Slaby <jirislaby@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f25.google.com ([209.85.220.25]:36203 "EHLO
	mail-fx0-f25.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164AbZBNWo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 17:44:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch suggested by Jiri Slaby.

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---

This patch is based on:
    drivers/isdn/hardware/mISDN: fix sparse warnings: make symbols static

 drivers/isdn/hardware/mISDN/hfcpci.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index 2bb85c4..c7a855c 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -57,7 +57,7 @@ static int HFC_cnt;
 static uint debug;
 static uint poll, tics;
 static struct timer_list hfc_tl;
-static u32 hfc_jiffies;
+static ulong hfc_jiffies;
 
 MODULE_AUTHOR("Karsten Keil");
 MODULE_LICENSE("GPL");

