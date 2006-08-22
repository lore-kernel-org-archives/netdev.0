From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [2.6.19 PATCH 6/7] ehea: eHEA Makefile
Date: Tue, 22 Aug 2006 14:56:47 +0200
Message-ID: <200608221456.47616.ossthema@de.ibm.com>
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
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:27380 "EHLO
	mtagate5.uk.ibm.com") by vger.kernel.org with ESMTP id S932238AbWHVNgz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 09:36:55 -0400
Content-Disposition: inline
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com> 


 drivers/net/ehea/Makefile |    7 +++++++
 1 file changed, 7 insertions(+)



--- linux-2.6.18-rc4-git1-orig/drivers/net/ehea/Makefile	1969-12-31 16:00:00.000000000 -0800
+++ kernel/drivers/net/ehea/Makefile	2006-08-22 06:05:26.965093280 -0700
@@ -0,0 +1,7 @@
+#
+# Makefile for the eHEA ethernet device driver for IBM eServer System p
+#
+
+ehea-y = ehea_main.o ehea_phyp.o ehea_qmr.o ehea_ethtool.o ehea_phyp.o
+obj-$(CONFIG_EHEA) += ehea.o
+
