From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/3] NetXen: 64-bit memory fixes
Date: Sat, 02 Dec 2006 00:32:55 -0500
Message-ID: <45711007.5030704@garzik.org>
References: <200612011340.kB1DeEhR014690@dut39.unminc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brazilnut@us.ibm.com,
	netxenproj@linsyssoft.com, rob@netxen.com, romieu@fr.zoreil.com,
	sanjeev@netxen.com, shemminger@osdl.org, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60590 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1162821AbWLBFdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Dec 2006 00:33:00 -0500
To: "Amit S. Kale" <amitkale@netxen.com>
In-Reply-To: <200612011340.kB1DeEhR014690@dut39.unminc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Amit S. Kale wrote:
> NetXen: 1G/10G Ethernet driver updates
> 	- These fixes take care of driver on machines with >4G memory
> 	- Driver cleanup
> 
> Signed-off-by: Amit S. Kale <amitkale@netxen.com>
> 
>  netxen_nic.h          |   29 +++++--
>  netxen_nic_ethtool.c  |   19 ++--
>  netxen_nic_hw.c       |    4 
>  netxen_nic_hw.h       |    4 
>  netxen_nic_init.c     |   51 +++++++++++-
>  netxen_nic_isr.c      |    3 
>  netxen_nic_main.c     |  204 +++++++++++++++++++++++++++++++++++++++++++++++---
>  netxen_nic_phan_reg.h |   10 +-

NAK, the driver itself should not be doing bounce buffering


