From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/6] qed: update series
Date: Wed, 2 Mar 2016 20:25:59 +0200
Message-ID: <1456943165-15198-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:28441 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756033AbcCBS0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 13:26:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series tries to improve general configuration by changing
configuration to better suit B0 boards and allow more available
resources to each physical function.
In additition, it contains some small fixes and semantic changes.

Dave,

Please consider applying this series to `net-next'.

Thanks,
Yuval

Yuval Mintz (6):
  qed: Correct BAR sizes for older MFW
  qed: Support B0 instead of A0
  qed: Move statistics to L2 code
  qed: Fix error flow on slowpath start
  qed: Remove unused NVM vendor ID
  qed: Learn number of functions from HW

 drivers/net/ethernet/qlogic/qed/qed.h          |   5 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c      | 462 ++++++++-----------------
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h  |  11 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h      |   2 +-
 drivers/net/ethernet/qlogic/qed/qed_l2.c       | 323 +++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_main.c     |  10 +-
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h |   2 +
 7 files changed, 486 insertions(+), 329 deletions(-)

-- 
1.9.3
