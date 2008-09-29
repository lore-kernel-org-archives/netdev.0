From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/3] myri10ge: rename main file into myri10ge_main.c
Date: Mon, 29 Sep 2008 03:34:36 +0200
Message-ID: <48E030AC.3060605@myri.com>
References: <48E02FD1.2010502@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1977 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752463AbYI2BeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Sep 2008 21:34:05 -0400
In-Reply-To: <48E02FD1.2010502@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To prepare myri10ge.c split into multiple files, rename
it to myri10ge_main.c first.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/Makefile                      |    2 ++
 .../net/myri10ge/{myri10ge.c => myri10ge_main.c}   |    0 
 2 files changed, 2 insertions(+), 0 deletions(-)
 rename drivers/net/myri10ge/{myri10ge.c => myri10ge_main.c} (100%)

diff --git a/drivers/net/myri10ge/Makefile b/drivers/net/myri10ge/Makefile
index 5df8916..597440c 100644
--- a/drivers/net/myri10ge/Makefile
+++ b/drivers/net/myri10ge/Makefile
@@ -3,3 +3,5 @@
 #
 
 obj-$(CONFIG_MYRI10GE) += myri10ge.o
+
+myri10ge-objs := myri10ge_main.o
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge_main.c
similarity index 100%
rename from drivers/net/myri10ge/myri10ge.c
rename to drivers/net/myri10ge/myri10ge_main.c
-- 
1.5.6.5



