From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH] vmxnet3: remove duplicate #include
Date: Wed, 28 Oct 2009 09:30:40 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.0910280910250.24555@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: weiyi.huang@gmail.com, pv-drivers@vmware.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:60782 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754850AbZJ1Qag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 12:30:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Remove duplicate headerfile includes from vmxnet3_int.h

Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
Signed-off-by: Bhavesh Davda <davda@vmware.com>

---

diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 3c0d70d..4450816 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -27,16 +27,11 @@
 #ifndef _VMXNET3_INT_H
 #define _VMXNET3_INT_H
 
-#include <linux/types.h>
 #include <linux/ethtool.h>
 #include <linux/delay.h>
-#include <linux/device.h>
 #include <linux/netdevice.h>
 #include <linux/pci.h>
-#include <linux/ethtool.h>
 #include <linux/compiler.h>
-#include <linux/module.h>
-#include <linux/moduleparam.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/ioport.h>
