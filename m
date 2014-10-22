From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: [PATCH 0/6 resend] s390: network patches for net-next
Date: Wed, 22 Oct 2014 12:18:01 +0200
Message-ID: <1413973087-18740-1-git-send-email-blaschka@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Frank Blaschka <blaschka@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:35029 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755078AbaJVKSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 06:18:16 -0400
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <blaschka@linux.vnet.ibm.com>;
	Wed, 22 Oct 2014 11:18:14 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

looks like there was a problem with my previous posting. Hope this time
it will work. Sorry for any inconvenience. The patches are mostly
cleanups and small enhancements for net-next

Thanks,
        Frank

Thomas Richter (6):
  qeth: qeth_core_main make local functions static
  qeth: fix some trace formating issues
  qeth: make local functions static in qeth_l3 module
  qeth: s390 ethernet device driver dependency
  lcs: replace sscanf by kstrto function
  ctcm: replace sscanf by kstrto function

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
