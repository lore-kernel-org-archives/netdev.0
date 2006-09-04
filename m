From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [2.6.19 PATCH 6/7] ehea: eHEA Makefile
Date: Mon, 4 Sep 2006 12:42:51 +0200
Message-ID: <200609041242.51942.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:51604 "EHLO
	mtagate4.uk.ibm.com") by vger.kernel.org with ESMTP id S964780AbWIDLY6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 07:24:58 -0400
Content-Disposition: inline
To: netdev <netdev@vger.kernel.org>, Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com> 


 drivers/net/ehea/Makefile |    6 ++++++
 1 file changed, 6 insertions(+)



--- linux-2.6.18-rc6-orig/drivers/net/ehea/Makefile	1970-01-01 01:00:00.000000000 +0100
+++ kernel/drivers/net/ehea/Makefile	2006-09-04 11:41:18.000000000 +0200
@@ -0,0 +1,6 @@
+#
+# Makefile for the eHEA ethernet device driver for IBM eServer System p
+#
+ehea-y = ehea_main.o ehea_phyp.o ehea_qmr.o ehea_ethtool.o ehea_phyp.o
+obj-$(CONFIG_EHEA) += ehea.o
+

-- 
VGER BF report: H 0
