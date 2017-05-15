From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH net-next 0/2] ldmvsw: port removal stability
Date: Mon, 15 May 2017 10:51:06 -0700
Message-ID: <1494870668-65047-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20513 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757956AbdEORzK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 13:55:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under heavy reboot stress testing we found a couple of timing issues
when removing the device that could cause the kernel great heartburn,
addressed by these two patches.

Shannon Nelson (1):
  ldmvsw: stop the clean timer at beginning of remove

Thomas Tai (1):
  ldmvsw: unregistering netdev before disable hardware

 drivers/net/ethernet/sun/ldmvsw.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)
