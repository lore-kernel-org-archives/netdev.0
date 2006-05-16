From: "Ron Mercer" <ron.mercer@qlogic.com>
Subject: [RFC] new qla3xxx NIC Driver v2.02.00k19
Date: Tue, 16 May 2006 10:52:40 -0700
Message-ID: <0BB3E5E7462EEA4295BC02D49691DC070D32F3@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-driver@qlogic.com>, "Ying Ping Lok" <ying.lok@qlogic.com>,
	"Mike Metskas" <mike.metskas@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.qlogic.com ([198.70.193.2]:11357 "EHLO avexch1.qlogic.com")
	by vger.kernel.org with ESMTP id S932364AbWEPRwl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 13:52:41 -0400
Content-class: urn:content-classes:message
To: "Ron Mercer" <ron.mercer@qlogic.com>, <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All,

Second submission for the upstream inclusion of the qla3xxx Ethernet
driver. This is a complementary network driver for our ISP4XXX parts.
There is a concurrent effort underway to get the iSCSI driver (qla4xxx)
integrated upstream as well.

The following files are included and have been posted to the link below:

LICENSE.qla3xxx
qla3xxxsrc-v2.02.00k19.tgz

ftp://ftp.qlogic.com/outgoing/linux/network/upstream/2.02.00k19/

Original submission:
http://marc.theaimsgroup.com/?l=linux-netdev&m=114254712431781&w=2

Comments from original submission:
http://marc.theaimsgroup.com/?l=linux-netdev&m=114263130100996&w=2

Changes in this release:
-Removed double buffering on receives.
-Added NAPI support.
-Removed elements in device structure that were already in netdev.
-Changed to pci_xxx_consistent calls instead of dma_xxx_coherent.
-Added ethtool support.
-Changed debug printing to use netif_msg_xxx.
-Changed DPC thread to work queue.
-Inlined numerous functions.
-Changed all functions to statics.
-Combined all source files to a single file.


Work in progress:
-Removal of debug functions.
-Possible changes for big endian architecture.

The driver has been built and tested using kernel 2.6.16-rc5.


Looking forward to any and all feedback.

Regards,

Ron Mercer
Qlogic Corporation
