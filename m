From: Andi Kleen <ak@suse.de>
Subject: fix s2io driver compilation
Date: Tue, 23 Mar 2004 07:09:31 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040323060931.GA32533@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ravinandan.arakali@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Without this patch it won't build with NAPI enabled.

(against the patch Jeff posted)

-Andi


diff -u linux-2.6.4/drivers/net/s2io.c-o linux-2.6.4/drivers/net/s2io.c
--- linux-2.6.4/drivers/net/s2io.c-o	2004-03-22 22:01:26.000000000 -0800
+++ linux-2.6.4/drivers/net/s2io.c	2004-03-22 22:04:05.490715632 -0800
@@ -2339,9 +2339,7 @@
 	struct net_device *dev = (struct net_device *) dev_id;
 	nic_t *sp = dev->priv;
 	XENA_dev_config_t *bar0 = (XENA_dev_config_t *) sp->bar0;
-#ifndef CONFIG_S2IO_NAPI
 	int i, ret;
-#endif
 	u64 reason = 0, general_mask = 0;
 	mac_info_t *mac_control;
 	struct config_param *config;
