From: "Ron Mercer" <ron.mercer@qlogic.com>
Subject: RE: New Qlogic qla3xxx NIC Driver v2.02.00k31 for upstream inclusion
Date: Wed, 21 Jun 2006 14:24:27 -0700
Message-ID: <0BB3E5E7462EEA4295BC02D49691DC07176751@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-driver@qlogic.com>, <netdev@vger.kernel.org>,
	<akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.qlogic.com ([198.70.193.2]:14719 "EHLO avexch1.qlogic.com")
	by vger.kernel.org with ESMTP id S1751399AbWFUVY2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 17:24:28 -0400
Content-class: urn:content-classes:message
To: <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

Please add the qla3xxx NIC driver to the next netdev-2.6 GIT tree. 

Regards,
Ron Mercer

> -----Original Message-----
> From: Ron Mercer 
> Sent: Monday, June 12, 2006 1:33 PM
> To: 'jeff@garzik.org'
> Cc: 'linux-driver@qlogic.com'; 'netdev@vger.kernel.org'
> Subject: New Qlogic qla3xxx NIC Driver v2.02.00k31 for 
> upstream inclusion
> 
> Jeff,
> 
> Please find the Qlogic qla3xxx Ethernet driver posted at the 
> URL below. This is a complementary network driver for our 
> ISP4XXX parts.
> There is a concurrent effort underway to get the iSCSI driver 
> (qla4xxx) integrated upstream as well.
> 
> I have been through several iterations with the linux-netdev 
> list and have had much response from Stephen Hemminger. In 
> his last response he suggested I submit the driver to you.
> 
> This submission is contained in a patch file that does the following:
> 
> Adds:
> drivers/net/qla3xxx.c
> drivers/net/qla3xxx.h
> 
> Modifies:
> MAINTAINERS
> drivers/net/Makefile
> drivers/net/Kconfig
> 
> Patch file qla3xxxpatch1-v2.02.00-k31.txt is at the following link:
> 
>
ftp://ftp.qlogic.com/outgoing/linux/network/upstream/2.02.00k31/qla3xxxp
atch1-v2.02.00-k31.txt
> 
> 
> Some notes on the driver/hardware:
> 
> - Built and tested using kernel 2.6.17-rc4.
> - The chip supports two ethernet and two iSCSI functions.
> - The functions ql_sem_lock, ql_sem_spinlock, ql_sem_unlock, 
> and ql_wait_for_drvr_lock are used to protect resources that 
> are shared across the network and iSCSI functions.  This 
> protection is mostly during chip initialization and resets, 
> but also include link management.
> - The PHY/MII are not exported through ethtool due to the 
> fact that the iSCSI function will control the common link at 
> least 50% of the time.
> 
> 
> 
> Regards,
> 
> Ron Mercer
> Qlogic Corporation
> 
