From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: [PATCH 0/6] s390: network patches for net-next
Date: Tue, 21 Oct 2014 17:15:25 +0200
Message-ID: <1413904531-55663-1-git-send-email-blaschka@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Frank Blaschka <blaschka@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:53860 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755060AbaJUPPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 11:15:44 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <blaschka@linux.vnet.ibm.com>;
	Tue, 21 Oct 2014 16:15:42 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

these are mostly cleanups and small enhancements for net-next

Thanks,
        Frank

Thomas Richter (6):
  qeth: qeth_core_main make local functions static
  qeth: fix some trace formating issues
  qeth: make local functions static in qeth_l3 module
  qeth: s390 ethernet device driver dependency
  lcs: replace sscanf by kstrtoXXX function
  ctcm: replace sscanf by kstrtoXXX function

 drivers/s390/net/Kconfig          |  2 +-
 drivers/s390/net/ctcm_sysfs.c     |  8 ++++----
 drivers/s390/net/lcs.c            | 11 ++++++-----
 drivers/s390/net/qeth_core.h      | 16 ----------------
 drivers/s390/net/qeth_core_main.c | 24 ++++++++++++++++++------
 drivers/s390/net/qeth_l2_main.c   |  2 +-
 drivers/s390/net/qeth_l3.h        |  4 ----
 drivers/s390/net/qeth_l3_main.c   | 10 +++++-----
 8 files changed, 35 insertions(+), 42 deletions(-)

-- 
1.8.5.5
