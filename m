From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.9 4/11] b44: Add MODULE_VERSION
Date: Wed, 20 Oct 2004 14:36:39 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020143639.R8775@tuxdriver.com>
References: <20041020141146.C8775@tuxdriver.com> <20041020141753.G8775@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com,
        davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <20041020141753.G8775@tuxdriver.com>; from linville@tuxdriver.com on Wed, Oct 20, 2004 at 02:17:53PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add MODULE_VERSION to b44 driver.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/b44.c |    1 +
 1 files changed, 1 insertion(+)

Re-send -- forgot Signed-off-by line...

--- linux-2.6.9/drivers/net/b44.c.orig
+++ linux-2.6.9/drivers/net/b44.c
@@ -79,6 +79,7 @@ MODULE_DESCRIPTION("Broadcom 4400 10/100
 MODULE_LICENSE("GPL");
 MODULE_PARM(b44_debug, "i");
 MODULE_PARM_DESC(b44_debug, "B44 bitmapped debugging message enable value");
+MODULE_VERSION(DRV_MODULE_VERSION);
 
 static int b44_debug = -1;	/* -1 == use B44_DEF_MSG_ENABLE as value */
 
