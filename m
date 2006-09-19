From: Pradeep Dalvi <pradeep@netxen.com>
Subject: Re: [PATCH 2.6.18-rc7 5/9] NetXen: ethtool interface
Date: Tue, 19 Sep 2006 08:26:32 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0609190825250.25990@dut39>
References: <Pine.LNX.4.64.0609151124560.7710@dut39> <Pine.LNX.4.64.0609151145510.7710@dut39>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jeff@garzik.org>,
	Sanjeev Jorapur <sanjeev@netxen.com>,
	Rob Mapes <rob@netxen.com>, unmproj@linsyssoft.com,
	brazilnut@us.ibm.com, wendyx@us.ibm.com,
	"Amit S. Kale" <amitkale@netxen.com>,
	Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:61553 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S1750902AbWISP0c
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 11:26:32 -0400
To: netdev@vger.kernel.org
In-Reply-To: <Pine.LNX.4.64.0609151145510.7710@dut39>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff -u linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_ethtool.c linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_ethtool.c
--- linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_ethtool.c	2006-09-15 10:51:59.000000000 -0700
+++ linux-2.6.18-rc7/drivers/net/netxen/netxen_nic_ethtool.c	2006-09-19 07:51:20.000000000 -0700
@@ -115,7 +115,7 @@
  	uint32_t fw_minor = 0;
  	uint32_t fw_build = 0;

-	strncpy(drvinfo->driver, "NetXen", 32);
+	strncpy(drvinfo->driver, "netxen_nic", 32);
  	strncpy(drvinfo->version, NETXEN_NIC_LINUX_VERSIONID, 32);
  	fw_major = readl(NETXEN_CRB_NORMALIZE(adapter,
  					      NETXEN_FW_VERSION_MAJOR));
@@ -551,7 +551,7 @@
  			return 0;
  		}

-		/* netxen_niu_gb_mii_mgmt_indicators_t is read only */
+		/* netxen_niu_gb_mii_mgmt_indicators is read only */
  		netxen_nic_read_w0(adapter,
  				   NETXEN_NIU_GB_MII_MGMT_INDICATE(port->
  								   portnum),
@@ -579,7 +579,7 @@
  			return 0;
  		}

-		/* netxen_niu_gb_interface_status_t is read only */
+		/* netxen_niu_gb_interface_status is read only */
  		netxen_nic_read_w0(adapter,
  				   NETXEN_NIU_GB_INTERFACE_STATUS(port->
  								  portnum),

