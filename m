From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.9 10/11] bonding: Add MODULE_VERSION
Date: Wed, 20 Oct 2004 14:29:54 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020142954.M8775@tuxdriver.com>
References: <20041020141146.C8775@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com,
        ctindel@users.sourceforge.net, fubar@us.ibm.com
Content-Disposition: inline
In-Reply-To: <20041020141146.C8775@tuxdriver.com>; from linville@tuxdriver.com on Wed, Oct 20, 2004 at 02:11:46PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add MODULE_VERSION to bonding driver.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/bonding/bond_main.c |    1 +
 1 files changed, 1 insertion(+)

--- linux-2.6.9/drivers/net/bonding/bond_main.c.orig
+++ linux-2.6.9/drivers/net/bonding/bond_main.c
@@ -4700,6 +4700,7 @@ static void __exit bonding_exit(void)
 module_init(bonding_init);
 module_exit(bonding_exit);
 MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
 MODULE_DESCRIPTION(DRV_DESCRIPTION ", v" DRV_VERSION);
 MODULE_AUTHOR("Thomas Davis, tadavis@lbl.gov and many others");
 MODULE_SUPPORTED_DEVICE("most ethernet devices");
