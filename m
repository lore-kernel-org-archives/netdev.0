From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: [PATCH] ibm_newemac: Fix typo in flow control config option
Date: Fri, 24 Oct 2008 09:53:14 -0400
Message-ID: <20081024135314.GA2299@yoda.jdub.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@lst.de, linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:37163 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755813AbYJXNyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 09:54:55 -0400
Received: by yw-out-2324.google.com with SMTP id 9so293917ywe.1
        for <netdev@vger.kernel.org>; Fri, 24 Oct 2008 06:54:54 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent build fix for ibm_newemac has a typo in the config
option #ifdef used for disabling flow control.  This corrects
it to the proper Kconfig option name.

Reported-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>

---

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 2ee2622..901212a 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2605,7 +2605,7 @@ static int __devinit emac_init_config(struct emac_instance *dev)
 		    of_device_is_compatible(np, "ibm,emac-440gr"))
 			dev->features |= EMAC_FTR_440EP_PHY_CLK_FIX;
 		if (of_device_is_compatible(np, "ibm,emac-405ez")) {
-#ifdef CONFIG_IBM_NEW_EMAC_NO_FLOW_CONTROL
+#ifdef CONFIG_IBM_NEW_EMAC_NO_FLOW_CTRL
 			dev->features |= EMAC_FTR_NO_FLOW_CONTROL_40x;
 #else
 			printk(KERN_ERR "%s: Flow control not disabled!\n",
