From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.9 1/11] tg3: Add MODULE_VERSION
Date: Wed, 20 Oct 2004 14:33:58 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020143358.O8775@tuxdriver.com>
References: <20041020141146.C8775@tuxdriver.com> <20041020141440.D8775@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com,
        davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <20041020141440.D8775@tuxdriver.com>; from linville@tuxdriver.com on Wed, Oct 20, 2004 at 02:14:40PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add MODULE_VERSION to tg3 driver.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/tg3.c |    1 +
 1 files changed, 1 insertion(+)

Re-send -- forgot Signed-off-by line...

--- linux-2.6.9/drivers/net/tg3.c.orig
+++ linux-2.6.9/drivers/net/tg3.c
@@ -143,6 +143,7 @@ MODULE_DESCRIPTION("Broadcom Tigon3 ethe
 MODULE_LICENSE("GPL");
 MODULE_PARM(tg3_debug, "i");
 MODULE_PARM_DESC(tg3_debug, "Tigon3 bitmapped debugging message enable value");
+MODULE_VERSION(DRV_MODULE_VERSION);
 
 static int tg3_debug = -1;	/* -1 == use TG3_DEF_MSG_ENABLE as value */
 
