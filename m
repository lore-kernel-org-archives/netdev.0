From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 2/2] More ethtool support for sis900 and warning fix
Date: Sat, 12 Mar 2005 11:39:41 +0100 (CET)
Message-ID: <20050312103941.27851.65526@localhost.localdomain>
References: <20050312103939.27851.24067@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; charset="us-ascii";
	boundary="===============0603660046=="
Content-Transfer-Encoding: 7bit
In-Reply-To: <20050312103939.27851.24067@localhost.localdomain>
To: netdev@oss.sgi.com, jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a MIME message, see the first attachment for the text
and the second for the patch
--===============0603660046==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit


Fix for a warning introduced with the patch for netconsole support.


Signed-off-by: Daniele Venzano <webvenza@libero.it>


--===============0603660046==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 102)
+++ b/drivers/net/sis900.c	(revision 103)
@@ -197,7 +197,10 @@ MODULE_PARM_DESC(multicast_filter_limit,
 MODULE_PARM_DESC(max_interrupt_work, "SiS 900/7016 maximum events handled per interrupt");
 MODULE_PARM_DESC(sis900_debug, "SiS 900/7016 bitmapped debugging message level");
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
 static void sis900_poll(struct net_device *dev);
+#endif
+
 static int sis900_open(struct net_device *net_dev);
 static int sis900_mii_probe (struct net_device * net_dev);
 static void sis900_init_rxfilter (struct net_device * net_dev);

--===============0603660046==--
