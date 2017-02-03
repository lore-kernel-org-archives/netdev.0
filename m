From: Mao Wenan <maowenan@huawei.com>
Subject: [PATCH net-next 0/2] enable relax order mode in intel NIC's driver
Date: Fri, 3 Feb 2017 17:30:31 +0800
Message-ID: <1486114233-9800-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <alexander.duyck@gmail.com>,
        <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:32698 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752323AbdBCJbp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 04:31:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches give a way to enable relax order mode in intel
NIC's driver. CONFIG_ARCH_WANT_RELAX_ORDER is a common macro for
CPU architecture to use relax order, it can be defined in
arch/xxx/Kconfig, such as arch/sparc/Kconfig; but for some special
CPU architecture, such as arm64, it can't be defined in
arch/arm64/Kconfig, because not all of arm64 CPU must use relax order
mode, so this patch give a way to select
CONFIG_ARCH_WANT_RELAX_ORDER in intel NIC's Kconfig.

Mao Wenan (2):
  ixgbevf and 82598 relax order mode support
  add one config to select relax order mode in intel NIC's Kconfig

 drivers/net/ethernet/intel/Kconfig                | 15 +++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c    |  4 ++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  2 +-
 3 files changed, 18 insertions(+), 3 deletions(-)

-- 
2.7.0
