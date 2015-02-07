From: Bas Peters <baspeters93@gmail.com>
Subject: [PATCH 4/7] drivers: isdn: act2000: module.c: remove NULL-initialization of static variable.
Date: Sat,  7 Feb 2015 20:05:26 +0100
Message-ID: <1423335929-24926-5-git-send-email-baspeters93@gmail.com>
References: <1423335929-24926-1-git-send-email-baspeters93@gmail.com>
Cc: julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	Bas Peters <baspeters93@gmail.com>
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423335929-24926-1-git-send-email-baspeters93@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

GCC takes care of this for us, thus it is not needed and theoretically
only hoggs memory, allbeit only a bit.
---
 drivers/isdn/act2000/module.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/act2000/module.c b/drivers/isdn/act2000/module.c
index 352916a..9359b36 100644
--- a/drivers/isdn/act2000/module.c
+++ b/drivers/isdn/act2000/module.c
@@ -28,7 +28,7 @@ static unsigned short act2000_isa_ports[] =
 static act2000_card *cards = (act2000_card *) NULL;
 
 /* Parameters to be set by insmod */
-static int   act_bus  =  0;
+static int   act_bus;
 static int   act_port = -1;  /* -1 = Autoprobe  */
 static int   act_irq  = -1;
 static char *act_id   = "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0";
-- 
2.1.0
