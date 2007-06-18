From: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Subject: [IPROUTE]: Fix symbolic link to tc-bfifo.8
Date: Mon, 18 Jun 2007 11:16:42 +0900 (JST)
Message-ID: <200706180216.l5I2Ghax000887@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx9.toshiba.co.jp ([202.33.96.51]:58304 "EHLO
	imx9.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753398AbXFRCUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2007 22:20:49 -0400
Received: from imx12.toshiba.co.jp (imx12 [61.202.160.132])
	by imx9.toshiba.co.jp  with ESMTP id l5I2KlkC013230
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 18 Jun 2007 11:20:47 +0900 (JST)
Received: from wall11.toshiba.co.jp (wall11 [133.199.90.149])
	by imx12.toshiba.co.jp  with ESMTP id l5I2GiFK017771
	for <netdev@vger.kernel.org>; Mon, 18 Jun 2007 11:16:44 +0900 (JST)
Received: (from root@localhost)
	by wall11.toshiba.co.jp  id l5I2Gi5x019553
	for netdev@vger.kernel.org; Mon, 18 Jun 2007 11:16:44 +0900 (JST)
Received: from mx2.toshiba.co.jp (localhost [127.0.0.1])
	by ovp11.toshiba.co.jp  with ESMTP id l5I2GhoU024753
	for <netdev@vger.kernel.org>; Mon, 18 Jun 2007 11:16:43 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


tc-pbfifo.8 does not exist because it was moved to tc-bfifo.8.

Signed-off-by: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
---
 Makefile |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/Makefile b/Makefile
index dbcb249..af0d5e4 100644
--- a/Makefile
+++ b/Makefile
@@ -52,8 +52,7 @@ install: all
 	install -m 0644 $(shell find etc/iproute2 -maxdepth 1 -type f) $(DESTDIR)$(CONFDIR)
 	install -m 0755 -d $(DESTDIR)$(MANDIR)/man8
 	install -m 0644 $(shell find man/man8 -maxdepth 1 -type f) $(DESTDIR)$(MANDIR)/man8
-	ln -sf tc-pbfifo.8  $(DESTDIR)$(MANDIR)/man8/tc-bfifo.8
-	ln -sf tc-pbfifo.8  $(DESTDIR)$(MANDIR)/man8/tc-pfifo.8
+	ln -sf tc-bfifo.8  $(DESTDIR)$(MANDIR)/man8/tc-pfifo.8
 	install -m 0755 -d $(DESTDIR)$(MANDIR)/man3
 	install -m 0644 $(shell find man/man3 -maxdepth 1 -type f) $(DESTDIR)$(MANDIR)/man3
 
-- 
1.5.2.2

