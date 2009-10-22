From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH] vmxnet3: remove duplicated #include
Date: Thu, 22 Oct 2009 16:58:33 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.0910221634130.23769@sbhatewara-dev1.eng.vmware.com>
References: <alpine.LRH.2.00.0910221631580.23769@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Huang Weiyi <weiyi.huang@gmail.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	pv-drivers@vmware.com
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:57156 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751263AbZJVX63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 19:58:29 -0400
In-Reply-To: <alpine.LRH.2.00.0910221631580.23769@sbhatewara-dev1.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Remove duplicate headerfile includes from vmxnet3_int.h

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
Signed-off-by: Bhavesh Davda <davda@vmware.com>

---

diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 6bb9157..c4f8f04 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -27,15 +27,11 @@
 #ifndef _VMXNET3_INT_H
 #define _VMXNET3_INT_H
 
-#include <linux/types.h>
 #include <linux/ethtool.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/pci.h>
-#include <linux/ethtool.h>
 #include <linux/compiler.h>
-#include <linux/module.h>
-#include <linux/moduleparam.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/ioport.h>

