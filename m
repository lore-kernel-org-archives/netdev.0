From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 04/19] isdn: Change variable type to bool
Date: Sun, 22 Sep 2013 00:27:36 +0200
Message-ID: <1379802471-30252-4-git-send-email-peter.senna@gmail.com>
References: <1379802471-30252-1-git-send-email-peter.senna@gmail.com>
Cc: isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Peter Senna Tschudin <peter.senna@gmail.com>
To: mac@melware.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1379802471-30252-1-git-send-email-peter.senna@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The variable noCh is only assigned the values true and false. Change
its type to bool.

The simplified semantic patch that find this problem is as
follows (http://coccinelle.lip6.fr/):

@exists@
type T;
identifier b;
@@
- T
+ bool
  b = ...;
  ... when any
  b = \(true\|false\)

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
---
 drivers/isdn/hardware/eicon/message.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/eicon/message.c b/drivers/isdn/hardware/eicon/message.c
index a82e542..05d889a 100644
--- a/drivers/isdn/hardware/eicon/message.c
+++ b/drivers/isdn/hardware/eicon/message.c
@@ -1207,7 +1207,7 @@ static byte connect_req(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
 	byte m;
 	static byte esc_chi[35] = {0x02, 0x18, 0x01};
 	static byte lli[2] = {0x01, 0x00};
-	byte noCh = 0;
+	bool noCh = false;
 	word dir = 0;
 	byte *p_chi = "";
 
-- 
1.8.3.1
