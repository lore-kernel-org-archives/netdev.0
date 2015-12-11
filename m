From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/7] s390 network patches
Date: Fri, 11 Dec 2015 11:38:50 +0100
Message-ID: <1449830337-26091-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: ubraunu@linux.vnet.ibm.com
To: davem@davemloft.net, mschwid2@linux.vnet.ibm.com,
	heicars2@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:53675 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482AbbLKKjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 05:39:08 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 11 Dec 2015 10:39:06 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some s390 related patches for net-next. Most important is
the skb_linearize af_iucv patch from Eugene solving traffic problems
in certain scenarios. The remaining patches are minor improvements.

Thanks, Ursula

Eugene Crosser (2):
  iucv: prevent information leak in iucv_message
  iucv: call skb_linearize() when needed

Markus Elfring (1):
  s390-ctcm: Delete unnecessary checks before the function call
    "channel_remove"

Rasmus Villemoes (1):
  qeth: get rid of redundant 0-termination

Ursula Braun (3):
  MAINTAINERS: switch to alternate IBM mail address
  qeth: initialize net_device with carrier off
  qeth: repair SBAL elements calculation

 MAINTAINERS                       |  4 ++--
 drivers/s390/net/ctcm_main.c      |  7 ++-----
 drivers/s390/net/qeth_core_main.c |  2 --
 drivers/s390/net/qeth_l2_main.c   |  1 +
 drivers/s390/net/qeth_l3_main.c   |  3 ++-
 net/iucv/af_iucv.c                | 22 ++++++++++++++++------
 6 files changed, 23 insertions(+), 16 deletions(-)

-- 
2.3.9
