From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 00/12] bnxt_en: Patches for net-next.
Date: Sun, 27 Dec 2015 18:19:17 -0500
Message-ID: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:19787 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754143AbbL0XTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 18:19:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mainly clean-ups, optimizations, and updating to the latest firmware
interface spec.

Michael Chan (12):
  bnxt_en: support hwrm_func_drv_unrgtr command
  bnxt_en: Optimize ring alloc and ring free functions.
  bnxt_en: Add support for upgrading APE/NC-SI firmware via Ethtool
    FLASHDEV
  bnxt_en: Increment checksum error counter only if NETIF_F_RXCSUM is
    set.
  bnxt_en: Allocate rx_cpu_rmap only if Accelerated RFS is enabled.
  bnxt_en: Don't treat single segment rx frames as GRO frames.
  bnxt_en: Check hardware resources before enabling NTUPLE.
  bnxt_en: Cleanup bnxt_hwrm_func_cfg().
  bnxt_en: Improve VF resource accounting.
  bnxt_en: Keep track of the ring group resource.
  bnxt_en: Update to Firmware interface spec 1.0.0.
  bnxt_en: Add BCM57301 & BCM57402 devices.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 330 +++++----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  13 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |   5 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_hsi.h     | 865 ++++++++--------------
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c   |  62 +-
 5 files changed, 544 insertions(+), 731 deletions(-)

-- 
1.8.3.1
