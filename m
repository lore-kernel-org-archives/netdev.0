From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] zd1211rw: fix a double include
Date: Thu, 18 Oct 2007 21:51:25 -0400
Message-ID: <11927586853636-git-send-email-linville@tuxdriver.com>
References: <20071018220946.GH8510@tuxdriver.com>
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Holger Schurig <hs4233@mail.mn-solutions.de>,
	"John W. Linville" <linville@tuxdriver.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2681 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933425AbXJSCIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 22:08:55 -0400
In-Reply-To: <20071018220946.GH8510@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Holger Schurig <hs4233@mail.mn-solutions.de>

This patch removes all double includes of the same file. This
makes scripts/checkincludes.pl happy.

Signed-off-by: Holger Schurig <hs4233@mail.mn-solutions.de>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
Jeff, I missed the zd1211rw hunk of the "double includes" patch.  Could
you apply this one manually?

Thanks,

John

 drivers/net/wireless/zd1211rw/zd_def.h          |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_def.h b/drivers/net/wireless/zd1211rw/zd_def.h
index deb99d1..505b4d7 100644
--- a/drivers/net/wireless/zd1211rw/zd_def.h
+++ b/drivers/net/wireless/zd1211rw/zd_def.h
@@ -21,7 +21,6 @@
 #include <linux/kernel.h>
 #include <linux/stringify.h>
 #include <linux/device.h>
-#include <linux/kernel.h>
 
 typedef u16 __nocast zd_addr_t;
 
-- 
1.5.2.4

