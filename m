From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] vmxnet3: spelling fixes
Date: Wed, 1 Apr 2015 15:33:08 -0700
Message-ID: <20150401153308.3116ac86@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org
To: Shreyas Bhatewara <sbhatewara@vmware.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36293 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566AbbDAWdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 18:33:04 -0400
Received: by padcy3 with SMTP id cy3so64838979pad.3
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 15:33:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c	2015-02-03 10:58:26.459635546 -0800
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c	2015-03-11 08:34:06.475326179 -0700
@@ -104,7 +104,7 @@ vmxnet3_rq_driver_stats[] = {
 					  rx_buf_alloc_failure) },
 };
 
-/* gloabl stats maintained by the driver */
+/* global stats maintained by the driver */
 static const struct vmxnet3_stat_desc
 vmxnet3_global_stats[] = {
 	/* description,         offset */
@@ -272,7 +272,7 @@ int vmxnet3_set_features(struct net_devi
 			adapter->shared->devRead.misc.uptFeatures &=
 			~UPT1_F_RXCSUM;
 
-		/* update harware LRO capability accordingly */
+		/* update hardware LRO capability accordingly */
 		if (features & NETIF_F_LRO)
 			adapter->shared->devRead.misc.uptFeatures |=
 							UPT1_F_LRO;
