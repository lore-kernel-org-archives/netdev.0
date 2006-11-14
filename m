From: "Ron Mercer" <ron.mercer@qlogic.com>
Subject: Re: [PATCH] qla3xxx: Add support for Qlogic ISP4032 chip.
Date: Tue, 14 Nov 2006 14:15:05 -0800
Message-ID: <0BB3E5E7462EEA4295BC02D49691DC07557F08@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:36549 "EHLO
	avexch1.qlogic.com") by vger.kernel.org with ESMTP id S966262AbWKNWPG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 17:15:06 -0500
Content-class: urn:content-classes:message
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
oops, that patch is borked (line-wrapped). will resend ASAP.

Ron Mercer.

 

 

 

>From 742b2f96f918225560f338b6f975c5c7ae23ba9c Mon Sep 17 00:00:00 2001
From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon, 13 Nov 2006 13:03:17 -0800
Subject: [PATCH] Add support for Qlogic ISP4032 chip.

Remove unused variables.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

---
drivers/net/qla3xxx.c |  831
+++++++++++++++++++++++++++++++------------------
drivers/net/qla3xxx.h |  107 +++++-
2 files changed, 614 insertions(+), 324 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c index
ec640f6..902135c 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -22,6 +22,7 @@ #include <linux/interrupt.h> #include <linux/errno.h>
#include <linux/ioport.h> #include <linux/ip.h>
+#include <linux/in.h>
#include <linux/if_arp.h>
#include <linux/if_ether.h>
#include <linux/netdevice.h>
@@ -38,7 +39,7 @@ #include "qla3xxx.h"

#define DRV_NAME  "qla3xxx"
#define DRV_STRING "QLogic ISP3XXX Network Driver"
-#define DRV_VERSION "v2.02.00-k36"
+#define DRV_VERSION "v2.03.00-k2"
#define PFX DRV_NAME " "
 
...

