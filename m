From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: [PATCH][R8169] Add endianess annotations to [RT]xDesc
Date: Wed, 16 May 2007 13:10:57 +0200
Message-ID: <200705161310.58575.eike-kernel@sf-tec.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sf-mail.de ([62.27.20.61]:42669 "EHLO mail.sf-mail.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759854AbXEPLRo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 07:17:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[R8169] Add endianess annotations to [RT]xDesc

Signed-off-by: Rolf Eike Beer <eike-kernel@sf-tec.de>

---
commit 8b36037f072047e61557506ee917dcc25680bd69
tree faafe5e664affabef85ff4dcab280338fd528fae
parent b26c4a9f50ccfade25e3699f616ce97590dc2cb7
author Rolf Eike Beer <eike-kernel@sf-tec.de> Wed, 16 May 2007 08:23:39 +0200
committer Rolf Eike Beer <eike-kernel@sf-tec.de> Wed, 16 May 2007 08:23:39 +0200

 drivers/net/r8169.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 45876a8..2261835 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -405,15 +405,15 @@ enum _DescStatusBit {
 #define RsvdMask	0x3fffc000
 
 struct TxDesc {
-	u32 opts1;
-	u32 opts2;
-	u64 addr;
+	__le32 opts1;
+	__le32 opts2;
+	__le64 addr;
 };
 
 struct RxDesc {
-	u32 opts1;
-	u32 opts2;
-	u64 addr;
+	__le32 opts1;
+	__le32 opts2;
+	__le64 addr;
 };
 
 struct ring_info {
