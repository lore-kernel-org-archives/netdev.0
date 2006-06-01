From: "Ron Mercer" <ron.mercer@qlogic.com>
Subject: [RFC] new qla3xxx NIC Driver v2.02.00k30
Date: Thu, 1 Jun 2006 14:40:20 -0700
Message-ID: <0BB3E5E7462EEA4295BC02D49691DC070D3A36@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-driver@qlogic.com>, "Ron Mercer" <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.qlogic.com ([198.70.193.2]:59967 "EHLO avexch1.qlogic.com")
	by vger.kernel.org with ESMTP id S1750997AbWFAVkU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 17:40:20 -0400
Content-class: urn:content-classes:message
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All,

Forth submission for the upstream inclusion of the qla3xxx Ethernet
driver. This is a complementary network driver for our ISP4XXX parts.
There is a concurrent effort underway to get the iSCSI driver (qla4xxx)
integrated upstream as well.

This submission is contained in a patch file that does the following:

Adds:
drivers/net/qla3xxx.c
drivers/net/qla3xxx.h

Modifies:
MAINTAINERS
drivers/net/Makefile
drivers/net/Kconfig

Built and tested using kernel 2.6.17-rc4.

Patch file qla3xxxpatch1-v2.02.00k30 is at the following link:

ftp://ftp.qlogic.com/outgoing/linux/network/upstream/2.02.00k30/

third submission:
http://marc.theaimsgroup.com/?l=linux-netdev&m=114867289310324&w=2

Comments from third submission:
http://marc.theaimsgroup.com/?l=linux-netdev&m=114868292920149&w=2



Changes in this release:
1.  Call unregister_netdev before doing any hardware tear down.
2.  Call pci_unmap_single before reference in eth_type_trans.
3.  Change kfree to free_netdev.
4.  Cleaned up indentation.
5.  Changed more globals to use const.
6.  ethtool get_link reports carrier state.
7.  Got rid if multicast list comparisons since kernel has to do it. 
8.  Added call to prefetch before sending packet up the stack.
9.  Renamed files to qla3xxx.c and qla3xxx.h.
10. Moved files to drivers/net and got rid of drivers/net/qla3xxx.
11. Updated Kconfig and Makefile to include driver build.
12. Cleaned up indents, eol whitespaces, and 80 column limits.
13. Added Ron Mercer to Maintainers list.

Looking forward to any and all feedback.

Regards,

Ron Mercer
Qlogic Corporation
