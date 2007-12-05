From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: [Fwd: PATCH 2.6.24-rc3-mm2 - build breakage - bnx2x depends on
 ZLIB_INFLATE]
Date: Wed, 05 Dec 2007 15:40:15 +0200
Message-ID: <1196862015.5204.16.camel@lb-tlvb-eliezer.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Lee Schermerhorn" <Lee.Schermerhorn@hp.com>,
	"jeff@garzik.org" <jeff@garzik.org>
To: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1646 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499AbXLENkZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 08:40:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Lee Schermerhorn sent this patch while you were away,
please apply.

Thanks,
Eliezer

-------- Forwarded Message --------
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
To: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
linux-kernel <linux-kernel@vger.kernel.org>
Subject: PATCH 2.6.24-rc3-mm2 - build breakage - bnx2x depends on
ZLIB_INFLATE
Date: Wed, 28 Nov 2007 12:25:24 -0800



Couldn't find one of these on the lists...

PATCH 2.6.24-rc3-mm1:  bnx2x depends on ZLIB_INFLATE

The bnx2x module depends on the zlib_inflate functions.  The
build will fail if ZLIB_INFLATE has not been selected manually
or by building another module that automatically selects it.

Modify BNX2X config option to 'select ZLIB_INFLATE' like BNX2
and others.  This seems to fix it.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Eliezer Tamir <eliezert@broadcom.com>

 drivers/net/Kconfig |    1 +
 1 file changed, 1 insertion(+)

Index: Linux/drivers/net/Kconfig
===================================================================
--- Linux.orig/drivers/net/Kconfig      2007-11-28 10:41:23.000000000
-0500
+++ Linux/drivers/net/Kconfig   2007-11-28 12:40:16.000000000 -0500
@@ -2606,6 +2606,7 @@ config TEHUTI
 config BNX2X
        tristate "Broadcom NetXtremeII 10Gb support"
        depends on PCI
+       select ZLIB_INFLATE
        help
          This driver supports Broadcom NetXtremeII 10 gigabit Ethernet
cards.
          To compile this driver as a module, choose M here: the module




