From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.9 7/11] 8139too: Add MODULE_VERSION
Date: Wed, 20 Oct 2004 14:23:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020142357.J8775@tuxdriver.com>
References: <20041020141146.C8775@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20041020141146.C8775@tuxdriver.com>; from linville@tuxdriver.com on Wed, Oct 20, 2004 at 02:11:46PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add MODULE_VERSION to 8139too driver.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/8139too.c |    1 +
 1 files changed, 1 insertion(+)

--- linux-2.6.9/drivers/net/8139too.c.8139too
+++ linux-2.6.9/drivers/net/8139too.c
@@ -598,6 +598,7 @@ struct rtl8139_private {
 MODULE_AUTHOR ("Jeff Garzik <jgarzik@pobox.com>");
 MODULE_DESCRIPTION ("RealTek RTL-8139 Fast Ethernet driver");
 MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
 
 MODULE_PARM (multicast_filter_limit, "i");
 MODULE_PARM (media, "1-" __MODULE_STRING(MAX_UNITS) "i");
