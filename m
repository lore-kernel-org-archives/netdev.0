From: Jan Glauber <jang@linux.vnet.ibm.com>
Subject: [PATCH] 3com: make 3c59x depend on HAS_IOPORT
Date: Wed, 05 Dec 2012 15:04:40 +0100
Message-ID: <1354716280.29038.2.camel@hal>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:46807 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753768Ab2LEOEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 09:04:51 -0500
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <jang@linux.vnet.ibm.com>;
	Wed, 5 Dec 2012 14:04:38 -0000
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qB5E4dix66388072
	for <netdev@vger.kernel.org>; Wed, 5 Dec 2012 14:04:39 GMT
Received: from d06av12.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qB5E4k4g018382
	for <netdev@vger.kernel.org>; Wed, 5 Dec 2012 07:04:46 -0700
Received: from [9.152.212.136] (dyn-9-152-212-136.boeblingen.de.ibm.com [9.152.212.136])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id qB5E4esQ018098
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 5 Dec 2012 07:04:46 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Glauber <jang@linux.vnet.ibm.com>

The 3com driver for 3c59x requires ioport_map. Since not all
architectures support IO port mapping make 3c59x dependent on HAS_IOPORT.

Signed-off-by: Jan Glauber <jang@linux.vnet.ibm.com>
---
 drivers/net/ethernet/3com/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/Kconfig b/drivers/net/ethernet/3com/Kconfig
index bad4fa6..eb56174 100644
--- a/drivers/net/ethernet/3com/Kconfig
+++ b/drivers/net/ethernet/3com/Kconfig
@@ -80,7 +80,7 @@ config PCMCIA_3C589
 
 config VORTEX
 	tristate "3c590/3c900 series (592/595/597) \"Vortex/Boomerang\" support"
-	depends on (PCI || EISA)
+	depends on (PCI || EISA) && HAS_IOPORT
 	select NET_CORE
 	select MII
 	---help---
