From: Pradeep Dalvi <pradeep@netxen.com>
Subject: Re: [PATCH 2.6.18-rc7 7/9] NetXen: hw access routines header file
Date: Tue, 19 Sep 2006 08:30:38 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0609190829060.25990@dut39>
References: <Pine.LNX.4.64.0609151124560.7710@dut39> <Pine.LNX.4.64.0609151151490.7710@dut39>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jeff@garzik.org>,
	Sanjeev Jorapur <sanjeev@netxen.com>,
	Rob Mapes <rob@netxen.com>, unmproj@linsyssoft.com,
	brazilnut@us.ibm.com, wendyx@us.ibm.com,
	"Amit S. Kale" <amitkale@netxen.com>,
	Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:44147 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S1751227AbWISPal
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 11:30:41 -0400
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0609151151490.7710@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -u linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_hw.h linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_hw.h
--- linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_hw.h	2006-09-15 10:51:59.000000000 -0700
+++ linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_hw.h	2006-09-19 07:51:20.000000000 -0700
@@ -368,8 +368,8 @@

  /* Promiscous mode options (GbE mode only) */
  typedef enum {
-	NETXEN_NIU_PROMISCOUS_MODE = 0,
-	NETXEN_NIU_NON_PROMISCOUS_MODE
+	NETXEN_NIU_PROMISC_MODE = 0,
+	NETXEN_NIU_NON_PROMISC_MODE
  } netxen_niu_prom_mode_t;

  /*
@@ -415,7 +415,20 @@
  #define netxen_xg_soft_reset(config_word)	\
  		set_bit(4, (unsigned long*)&config_word)

-/* Structure  unm_mac_addr_cntl_t for MAC CONTROL REGISTER */
+/*
+ * MAC Control Register
+ * 
+ * Bit 0-1   : id_pool0
+ * Bit 2     : enable_xtnd0
+ * Bit 4-5   : id_pool1
+ * Bit 6     : enable_xtnd1
+ * Bit 8-9   : id_pool2
+ * Bit 10    : enable_xtnd2
+ * Bit 12-13 : id_pool3
+ * Bit 14    : enable_xtnd3
+ * Bit 24-25 : mode_select
+ * Bit 28-31 : enable_pool
+ */

  #define netxen_nic_mcr_set_id_pool0(config, val)	\
  		((config) |= ((val) &0x03))
@@ -436,7 +449,7 @@
  #define netxen_nic_mcr_set_mode_select(config, val)	\
  		((config) |= (((val) & 0x03) << 24))
  #define netxen_nic_mcr_set_enable_pool(config, val)	\
-		((config) |= (((val) & 0x0f) << 26))
+		((config) |= (((val) & 0x0f) << 28))

  /* Set promiscuous mode for a GbE interface */
  int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter, int port,
