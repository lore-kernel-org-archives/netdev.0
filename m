From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.9 6/11] 3c59x: Add MODULE_VERSION
Date: Wed, 20 Oct 2004 14:21:32 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020142132.I8775@tuxdriver.com>
References: <20041020141146.C8775@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com,
        akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <20041020141146.C8775@tuxdriver.com>; from linville@tuxdriver.com on Wed, Oct 20, 2004 at 02:11:46PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add MODULE_VERSION to 3c59x driver.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/3c59x.c |    1 +
 1 files changed, 1 insertion(+)

--- linux-2.6.9/drivers/net/3c59x.c.orig
+++ linux-2.6.9/drivers/net/3c59x.c
@@ -277,6 +277,7 @@ MODULE_AUTHOR("Donald Becker <becker@scy
 MODULE_DESCRIPTION("3Com 3c59x/3c9xx ethernet driver "
 					DRV_VERSION " " DRV_RELDATE);
 MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
 
 MODULE_PARM(debug, "i");
 MODULE_PARM(global_options, "i");
