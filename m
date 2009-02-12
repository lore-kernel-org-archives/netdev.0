From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH] drivers/isdn/mISDN: fix sparse warnings: make symbols static
Date: Thu, 12 Feb 2009 20:32:41 +0100
Message-ID: <20090212193234.7485.41475.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:57575 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758452AbZBLTcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 14:32:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:
  drivers/isdn/mISDN/clock.c:44:1: warning: symbol 'iclock_lock' was not declared. Should it be static?
  drivers/isdn/mISDN/clock.c:45:9: warning: symbol 'iclock_count' was not declared. Should it be static?
  drivers/isdn/mISDN/clock.c:46:17: warning: symbol 'iclock_tv' was not declared. Should it be static?
  drivers/isdn/mISDN/clock.c:47:9: warning: symbol 'iclock_tv_valid' was not declared. Should it be static?
  drivers/isdn/mISDN/clock.c:48:20: warning: symbol 'iclock_current' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/isdn/mISDN/clock.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/mISDN/clock.c b/drivers/isdn/mISDN/clock.c
index 44d9c3d..f1bbc88 100644
--- a/drivers/isdn/mISDN/clock.c
+++ b/drivers/isdn/mISDN/clock.c
@@ -41,11 +41,11 @@
 
 static u_int *debug;
 static LIST_HEAD(iclock_list);
-DEFINE_RWLOCK(iclock_lock);
-u16	iclock_count;		/* counter of last clock */
-struct	timeval iclock_tv;	/* time stamp of last clock */
-int	iclock_tv_valid;	/* already received one timestamp */
-struct	mISDNclock *iclock_current;
+static DEFINE_RWLOCK(iclock_lock);
+static u16 iclock_count;		/* counter of last clock */
+static struct timeval iclock_tv;	/* time stamp of last clock */
+static int iclock_tv_valid;		/* already received one timestamp */
+static struct mISDNclock *iclock_current;
 
 void
 mISDN_init_clock(u_int *dp)

