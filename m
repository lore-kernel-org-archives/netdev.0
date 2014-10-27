From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] net/irda: include linux/uaccess.h instead of asm/uaccess.h
Date: Mon, 27 Oct 2014 19:00:08 +0100
Message-ID: <1414432809-29054-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/irda/ircomm/ircomm_tty_ioctl.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/irda/ircomm/ircomm_tty_ioctl.c b/net/irda/ircomm/ircomm_tty_ioctl.c
index ce94385..2db24bd 100644
--- a/net/irda/ircomm/ircomm_tty_ioctl.c
+++ b/net/irda/ircomm/ircomm_tty_ioctl.c
@@ -31,8 +31,7 @@
 #include <linux/termios.h>
 #include <linux/tty.h>
 #include <linux/serial.h>
-
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 
 #include <net/irda/irda.h>
 #include <net/irda/irmod.h>
-- 
1.9.1
