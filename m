From: =?UTF-8?B?TsOpbWV0aCBNw6FydG9u?= <nm127@freemail.hu>
Subject: [PATCH] 8139too: add missing brackets
Date: Mon, 16 Jun 2008 07:09:56 +0200
Message-ID: <4855F5A4.4020109@freemail.hu>
References: <4853BB7B.4030905@freemail.hu> <48541173.7040905@freemail.hu> <4854B604.6080900@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	Trivial Patch Monkey <trivial@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Newall <davidn@davidnewall.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752778AbYFPFKT@vger.kernel.org>
In-Reply-To: <4854B604.6080900@davidnewall.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: M=C3=A1rton N=C3=A9meth <nm127@freemail.hu>

Clean up the following error reported by checkpatch.pl:
 - Macros with complex values should be enclosed in parenthesis

The macro RTL8139_CAPS currently only used as a whole expression
to initialize board_info[] so this change won't change the resulting co=
de.

Signed-off-by: M=C3=A1rton N=C3=A9meth <nm127@freemail.hu>
---
--- a/drivers/net/8139too.c	2008-06-14 00:20:47.000000000 +0200
+++ b/drivers/net/8139too.c	2008-06-16 07:03:20.000000000 +0200
@@ -219,7 +219,7 @@ enum {
 #define RTL8139B_IO_SIZE 256

 #define RTL8129_CAPS	HAS_MII_XCVR
-#define RTL8139_CAPS	HAS_CHIP_XCVR|HAS_LNK_CHNG
+#define RTL8139_CAPS	(HAS_CHIP_XCVR|HAS_LNK_CHNG)

 typedef enum {
 	RTL8139 =3D 0,
