From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch 2.6.9 3/11] e1000: Add MODULE_VERSION
Date: Wed, 20 Oct 2004 14:35:23 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020143523.Q8775@tuxdriver.com>
References: <20041020141146.C8775@tuxdriver.com> <20041020141657.F8775@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com,
        john.ronciak@intel.com, ganesh.venkatesan@intel.com
Content-Disposition: inline
In-Reply-To: <20041020141657.F8775@tuxdriver.com>; from linville@tuxdriver.com on Wed, Oct 20, 2004 at 02:16:57PM -0400
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add MODULE_VERSION to e1000 driver.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/e1000/e1000_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

Re-send -- forgot Signed-off-by line...

--- linux-2.6.9/drivers/net/e1000/e1000_main.c.orig
+++ linux-2.6.9/drivers/net/e1000/e1000_main.c
@@ -48,7 +48,8 @@ char e1000_driver_string[] = "Intel(R) P
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-char e1000_driver_version[] = "5.3.19-k2"DRIVERNAPI;
+#define DRV_VERSION "5.3.19-k2"DRIVERNAPI
+char e1000_driver_version[] = DRV_VERSION;
 char e1000_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
@@ -196,6 +197,7 @@ static struct pci_driver e1000_driver = 
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
 MODULE_DESCRIPTION("Intel(R) PRO/1000 Network Driver");
 MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
 
 static int debug = NETIF_MSG_DRV | NETIF_MSG_PROBE;
 module_param(debug, int, 0);
