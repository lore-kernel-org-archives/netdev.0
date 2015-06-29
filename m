From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: [net-next]vmxnet3: Bump up driver version number
Date: Mon, 29 Jun 2015 04:14:43 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1506290411550.12845@promg-1n-a-dhcp378.eng.vmware.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pv-drivers@vmware.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:43162 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752576AbbF2LNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 07:13:54 -0400
Received: from sc9-mailhost2.vmware.com (sc9-mailhost2.vmware.com [10.113.161.72])
	by smtp-outbound-1.vmware.com (Postfix) with ESMTP id B080E2872A
	for <netdev@vger.kernel.org>; Mon, 29 Jun 2015 04:13:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bump up the driver version number to reflect the changes done to
work with vmxnet3 adapter version 2

Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
---

diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index e9f1075..2652245 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -69,10 +69,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.3.5.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.4.2.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01030500
+#define VMXNET3_DRIVER_VERSION_NUM      0x01040200
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
