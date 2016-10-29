From: Mao Wenan <maowenan@huawei.com>
Subject: [PATCH] add one parameter wro_enable to enable relaxed ordering for IXGBE
Date: Sat, 29 Oct 2016 15:08:51 +0800
Message-ID: <1477724932-5440-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <jeffrey.t.kirsher@intel.com>, <intel-wired-lan@lists.osuosl.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:1824 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750748AbcJ2HJZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 03:09:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides a way to enable relaxed ordering, where it helps with performance in some architecture.
The default value of wro_enable is 0, if you want to enable relaxed ordering, please set wro_enable=1.

Mao Wenan (1):
  add one parameter wro_enable for IXGBE

 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  | 29 ++++++++++++++-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 28 +++++++++++++-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  9 ++++++++
 4 files changed, 41 insertions(+), 26 deletions(-)

-- 
2.5.0
