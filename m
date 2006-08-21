From: Pradeep Dalvi <pradeep@netxen.com>
Subject: Re: [PATCH 2.6.17 6/9] NetXen: Main header file (Name prefix change)
Date: Mon, 21 Aug 2006 03:05:41 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0608210304230.22771@dut39>
References: <Pine.LNX.4.64.0608180713480.6875@dut39> <Pine.LNX.4.64.0608180807300.6875@dut39>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"sanjeev@netxen.com" <sanjeev@netxen.com>,
	"unmproj@linsyssoft.com" <unmproj@linsyssoft.com>,
	"rob@netxen.com" <rob@netxen.com>, amitkale@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:65144 "EHLO
	mail.unminc.com") by vger.kernel.org with ESMTP id S1751832AbWHUKFn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 06:05:43 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0608180807300.6875@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -u linux-2.6.17/drivers/net/netxen/netxen_nic.h linux-2.6.17/drivers/net/netxen/netxen_nic.h
--- linux-2.6.17/drivers/net/netxen/netxen_nic.h	2006-08-17 07:12:34.000000000 -0700
+++ linux-2.6.17/drivers/net/netxen/netxen_nic.h	2006-08-21 02:20:00.000000000 -0700
@@ -550,8 +550,8 @@
  #define FLASH_SECONDARY_SIZE 	(USER_START-SECONDARY_START)
  #define NUM_PRIMARY_SECTORS	(0x20)
  #define NUM_CONFIG_SECTORS 	(1)
-int is_flash_supported(struct netxen_adapter *adapter);
-int get_flash_mac_addr(struct netxen_adapter *adapter, u64 mac[]);
+int netxen_is_flash_supported(struct netxen_adapter *adapter);
+int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, u64 mac[]);

  extern void netxen_change_ringparam(struct netxen_adapter *adapter);
  extern int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr,
@@ -817,9 +817,9 @@
  				 unsigned long off, int data);

  /* Functions from netxen_nic_init.c */
-void phantom_init(struct netxen_adapter *adapter);
-void load_firmware(struct netxen_adapter *adapter);
-int pinit_from_rom(struct netxen_adapter *adapter, int verbose);
+void netxen_phantom_init(struct netxen_adapter *adapter);
+void netxen_load_firmware(struct netxen_adapter *adapter);
+int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose);
  int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr, int *valp);

  /* Functions from netxen_nic_isr.c */
@@ -842,9 +842,9 @@
  int netxen_nic_unset_promisc_mode(struct netxen_port *port);
  void netxen_nic_stop_all_ports(struct netxen_adapter *adapter);
  void netxen_nic_stop_port(struct netxen_port *port);
-void initialize_adapter_sw(struct netxen_adapter *adapter);
-void initialize_adapter_hw(struct netxen_adapter *adapter);
-int init_firmware(struct netxen_adapter *adapter);
+void netxen_initialize_adapter_sw(struct netxen_adapter *adapter);
+void netxen_initialize_adapter_hw(struct netxen_adapter *adapter);
+int netxen_init_firmware(struct netxen_adapter *adapter);
  void netxen_free_hw_resources(struct netxen_adapter *adapter);
  void netxen_tso_check(struct netxen_adapter *adapter,
  		      struct cmd_desc_type0_t *desc, struct sk_buff *skb);

