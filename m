From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 6/7] ehea: eHEA Makefile
Date: Mon, 14 Aug 2006 18:31:30 +0200
Message-ID: <44E0A562.7040106@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-ppc <linuxppc-dev@ozlabs.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Marcus Eder <meder@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Thomas Klein <osstklei@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751542AbWHNQbe@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>


  drivers/net/ehea/Makefile |    7 +++++++
  1 file changed, 7 insertions(+)



--- linux-2.6.18-rc4-orig/drivers/net/ehea/Makefile	1969-12-31 16:00:00.000000000 -0800
+++ kernel/drivers/net/ehea/Makefile	2006-08-14 09:05:11.734271473 -0700
@@ -0,0 +1,7 @@
+#
+# Makefile for the eHEA ethernet device driver for IBM eServer System p
+#
+
+ehea-y = ehea_main.o ehea_phyp.o ehea_qmr.o ehea_ethtool.o ehea_phyp.o
+obj-$(CONFIG_EHEA) += ehea.o
+
