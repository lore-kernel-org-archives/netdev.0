From: Pradeep Dalvi <pradeep@netxen.com>
Subject: Re: [PATCH 2.6.18-rc7 9/9] NetXen: CRB reg definitions
Date: Tue, 19 Sep 2006 08:32:26 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0609190830490.25990@dut39>
References: <Pine.LNX.4.64.0609151124560.7710@dut39> <Pine.LNX.4.64.0609151201320.7710@dut39>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jeff@garzik.org>,
	Sanjeev Jorapur <sanjeev@netxen.com>,
	Rob Mapes <rob@netxen.com>, unmproj@linsyssoft.com,
	brazilnut@us.ibm.com, wendyx@us.ibm.com,
	"Amit S. Kale" <amitkale@netxen.com>,
	Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:22644 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S1751274AbWISPc3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 11:32:29 -0400
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0609151201320.7710@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -u linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_phan_reg.h linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_phan_reg.h
--- linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_phan_reg.h	2006-09-15 10:51:59.000000000 -0700
+++ linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_phan_reg.h	2006-09-19 07:51:20.000000000 -0700
@@ -30,26 +30,26 @@
  #ifndef __NIC_PHAN_REG_H_
  #define __NIC_PHAN_REG_H_

-/** 
- * CRB Registers or queue message done only at initialization time....
- **/
+/* 
+ * CRB Registers or queue message done only at initialization time.
+ */

-/**
+/*
   * The following 2 are the base adresses for the CRB registers and their
- * offsets will be added to get addresses for the index addresses.......
- **/
+ * offsets will be added to get addresses for the index addresses.
+ */
  #define NIC_CRB_BASE_PORT1	NETXEN_CAM_RAM(0x200)
  #define NIC_CRB_BASE_PORT2	NETXEN_CAM_RAM(0x250)

  #define NETXEN_NIC_REG(X)	(NIC_CRB_BASE_PORT1+(X))

-/**
+/*
   * CrbPortPhanCntrHi/Lo is used to pass the address of HostPhantomIndex address
   * which can be read by the Phantom host to get producer/consumer indexes from
   * Phantom/Casper. If it is not HOST_SHARED_MEMORY, then the following
   * registers will be used for the addresses of the ring's shared memory
   * on the Phantom.
- **/
+ */

  #define CRB_PHAN_CNTRL_LO_OFFSET	NETXEN_NIC_REG(0x00)
  #define CRB_PHAN_CNTRL_HI_OFFSET	NETXEN_NIC_REG(0x04)

