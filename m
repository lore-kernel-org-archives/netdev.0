From: "Ron Mercer" <ron.mercer@qlogic.com>
Subject: New Qlogic qla3xxx NIC Driver v2.02.00k34 for upstream inclusion
Date: Thu, 22 Jun 2006 15:37:17 -0700
Message-ID: <0BB3E5E7462EEA4295BC02D49691DC0717688F@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-driver@qlogic.com>,
	"Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.qlogic.com ([198.70.193.2]:55154 "EHLO avexch1.qlogic.com")
	by vger.kernel.org with ESMTP id S1030429AbWFVWhU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 18:37:20 -0400
Content-class: urn:content-classes:message
To: <jeff@garzik.org>, "Andrew Morton" <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Jeff/Andrew,

Please find the Qlogic qla3xxx Ethernet driver posted at the URL below.
This is a complementary network driver for our ISP4XXX parts.
There is a concurrent effort underway to get the iSCSI driver (qla4xxx)
integrated upstream as well.

I have added the missing license that Francois pointed out, plus
Andrew's patch and suggestions from yesterday.

This submission is contained in a patch file that does the following:

Adds:
drivers/net/qla3xxx.c
drivers/net/qla3xxx.h
Documentation/networking/LICENSE.qla3xxx

Modifies:
MAINTAINERS
drivers/net/Makefile
drivers/net/Kconfig

Patch file qla3xxxpatch1-v2.02.00-k34.txt is at the following link:

ftp://ftp.qlogic.com/outgoing/linux/network/upstream/2.02.00k34/qla3xxxp
atch1-v2.02.00-k34.txt

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>

Some notes on the driver/hardware:

- Built and tested using kernel 2.6.17-rc4.
- The chip supports two ethernet and two iSCSI functions.
- The functions ql_sem_lock, ql_sem_spinlock, ql_sem_unlock, and
ql_wait_for_drvr_lock are used to protect resources that are shared
across the network and iSCSI functions.  This protection is mostly
during chip initialization and resets, but also include link management.
- The PHY/MII are not exported through ethtool due to the fact that the
iSCSI function will control the common link at least 50% of the time.



Regards,

Ron Mercer
Qlogic Corporation
