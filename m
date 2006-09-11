From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH 2/3] [IrDA] irda-usb needs firmware loader
Date: Mon, 11 Sep 2006 08:46:48 +0300
Message-ID: <20060911054648.GB6368@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.pp.htv.fi ([213.243.153.36]:28356 "EHLO smtp3.pp.htv.fi")
	by vger.kernel.org with ESMTP id S932180AbWIJWcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2006 18:32:36 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the inclusion of the stir421x code, we now need to select FW_LOADER
whenever we try to build the irda-usb code.

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 drivers/net/irda/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
index e9e6d99..7c8ccc0 100644
--- a/drivers/net/irda/Kconfig
+++ b/drivers/net/irda/Kconfig
@@ -287,6 +287,7 @@ comment "FIR device drivers"
 config USB_IRDA
 	tristate "IrDA USB dongles"
 	depends on IRDA && USB
+	select FW_LOADER
 	---help---
 	  Say Y here if you want to build support for the USB IrDA FIR Dongle
 	  device driver.  To compile it as a module, choose M here: the module
-- 
1.4.1.1

