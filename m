From: Roel Kluin <12o3l@tiscali.nl>
Subject: [PATCH] NET: parentheses around definitions
Date: Thu, 29 Nov 2007 15:39:15 +0100
Message-ID: <474ECF13.2040408@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amitkale@netxen.com, ram.vepa@neterion.com,
	santosh.rastapur@neterion.com, sivakumar.subramani@neterion.com,
	sreenivasa.honnur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out3.tiscali.nl ([195.241.79.178]:55956 "EHLO
	smtp-out3.tiscali.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755108AbXK2OjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 09:39:23 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are multiplictions wherein these defines are abused in:
drivers/net/netxen/netxen_nic_ethtool.c:705
drivers/net/s2io.c:350
--
Add parentheses to prevent operator precedence errors

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index cfb847b..b3c0a00 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -86,7 +86,7 @@ static const char netxen_nic_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Link_Test_on_offline"
 };
 
-#define NETXEN_NIC_TEST_LEN sizeof(netxen_nic_gstrings_test) / ETH_GSTRING_LEN
+#define NETXEN_NIC_TEST_LEN (sizeof(netxen_nic_gstrings_test) / ETH_GSTRING_LEN)
 
 #define NETXEN_NIC_REGS_COUNT 42
 #define NETXEN_NIC_REGS_LEN (NETXEN_NIC_REGS_COUNT * sizeof(__le32))
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 6326667..379d70b 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -346,7 +346,7 @@ static char ethtool_driver_stats_keys[][ETH_GSTRING_LEN] = {
 #define XFRAME_I_STAT_STRINGS_LEN ( XFRAME_I_STAT_LEN * ETH_GSTRING_LEN )
 #define XFRAME_II_STAT_STRINGS_LEN ( XFRAME_II_STAT_LEN * ETH_GSTRING_LEN )
 
-#define S2IO_TEST_LEN	sizeof(s2io_gstrings) / ETH_GSTRING_LEN
+#define S2IO_TEST_LEN	(sizeof(s2io_gstrings) / ETH_GSTRING_LEN)
 #define S2IO_STRINGS_LEN	S2IO_TEST_LEN * ETH_GSTRING_LEN
 
 #define S2IO_TIMER_CONF(timer, handle, arg, exp)		\
