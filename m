From: "Ron Mercer" <ron.mercer@qlogic.com>
Subject: [RFC] new qla3xxx NIC Driver v2.02.00k29
Date: Wed, 24 May 2006 16:06:46 -0700
Message-ID: <0BB3E5E7462EEA4295BC02D49691DC070D3692@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-driver@qlogic.com>, "Ying Ping Lok" <ying.lok@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.qlogic.com ([198.70.193.2]:11289 "EHLO avexch1.qlogic.com")
	by vger.kernel.org with ESMTP id S932125AbWEXXGr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 19:06:47 -0400
Content-class: urn:content-classes:message
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All,

Third submission for the upstream inclusion of the qla3xxx Ethernet
driver. This is a complementary network driver for our ISP4XXX parts.
There is a concurrent effort underway to get the iSCSI driver (qla4xxx)
integrated upstream as well.

The following files are included and have been posted to the link below:

LICENSE.qla3xxx
qla3xxxsrc-v2.02.00k29.tgz

ftp://ftp.qlogic.com/network/upstream/20.02.00k29/

Second submission:
http://marc.theaimsgroup.com/?l=linux-netdev&m=114780280407707&w=2

Comments from second submission:
http://marc.theaimsgroup.com/?l=linux-netdev&m=114782208808695&w=2



Changes in this release:
- Reordered code to remove forward declarations.
- Removed typedefs.
- Changed inter-driver hardware lock to use wait_event().
- Removed macros defined inside structure definitions.
- Removed volatile usage.
- Removed wrapper RD_REG_READ/WRITE macros for readl/writel
- Bug fix for msi logic.
- Removed unused debug print functions.
- probe now propagates error codes from api to caller.
- Removed internal send queue and lock dependency.


Looking forward to any and all feedback.

Regards,

Ron Mercer
Qlogic Corporation
