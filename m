From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 5/5] isdn/capi: correct argument types of command_2_index
Date: Wed, 10 Dec 2014 13:41:55 +0100 (CET)
Message-ID: <5467da669ad975e211e19a1b3cb6735c48fb5690.1418214588.git.tilman@imap.cc>
References: <cover.1418214588.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:33187 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755469AbaLJM7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 07:59:54 -0500
In-Reply-To: <cover.1418214588.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Utility function command_2_index is always called with arguments of
type u8. Adapt its declaration accordingly.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/capi/capiutil.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/capi/capiutil.c b/drivers/isdn/capi/capiutil.c
index 36c1b37..9846d82 100644
--- a/drivers/isdn/capi/capiutil.c
+++ b/drivers/isdn/capi/capiutil.c
@@ -201,7 +201,7 @@ static unsigned char *cpars[] =
 #define structTRcpyovl(x, y, l) memmove(y, x, l)
 
 /*-------------------------------------------------------*/
-static unsigned command_2_index(unsigned c, unsigned sc)
+static unsigned command_2_index(u8 c, u8 sc)
 {
 	if (c & 0x80)
 		c = 0x9 + (c & 0x0f);
-- 
1.9.2.459.g68773ac
