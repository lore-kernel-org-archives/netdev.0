From: Patrik Karlin <patrik.karlin@gmail.com>
Subject: [PATCH 4/5] drivers: atm: checkpatch.pl changed headers from asm/* to linux/* in eni.c
Date: Mon, 21 Jan 2013 00:12:54 +0100
Message-ID: <1358723575-8345-4-git-send-email-patrik.karlin@gmail.com>
References: <1358723575-8345-1-git-send-email-patrik.karlin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Patrik Karlin <patrik.karlin@gmail.com>
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:53296 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752636Ab3ATXN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 18:13:28 -0500
In-Reply-To: <1358723575-8345-1-git-send-email-patrik.karlin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the included headers from asm/* to linux/* for
header changes sugested by checkpatch.pl

Signed-off-by: Patrik K=C3=A5rlin <patrik.karlin@gmail.com>
---
 drivers/atm/eni.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index f4a136a..2877832 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -19,10 +19,10 @@
 #include <linux/atm_eni.h>
 #include <linux/bitops.h>
 #include <linux/slab.h>
-#include <asm/io.h>
+#include <linux/io.h>
 #include <linux/atomic.h>
-#include <asm/uaccess.h>
-#include <asm/string.h>
+#include <linux/uaccess.h>
+#include <linux/string.h>
 #include <asm/byteorder.h>
=20
 #include "tonga.h"
--=20
1.7.10.4
