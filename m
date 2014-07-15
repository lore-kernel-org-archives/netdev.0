From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 06/12] bonding: remove pr_fmt from bond_alb.c
Date: Tue, 15 Jul 2014 19:36:03 +0200
Message-ID: <1405445769-15394-7-git-send-email-vfalico@gmail.com>
References: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29957 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757344AbaGORko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 13:40:44 -0400
In-Reply-To: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To maintain the same message structure as netdev_* functions print.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_alb.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index ab0f7d2..2f9a241 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -19,8 +19,6 @@
  *
  */
 
-#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
-
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-- 
1.8.4
