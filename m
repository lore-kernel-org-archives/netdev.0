From: Manish Chopra <manish.chopra@cavium.com>
Subject: [PATCH net-next 0/7] qed/qede: Enhancements
Date: Fri, 30 Jun 2017 02:39:39 -0700
Message-ID: <20170630093946.18497-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>,
        <rahul.verma@cavium.com>, <sudarsana.kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0043.outbound.protection.outlook.com ([104.47.33.43]:57465
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751421AbdF3Jjw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 05:39:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series adds these below features support in qed/qede

1) Ntuple filter configuration [via ethtool -n/N]
2) EEE (energy efficient ethernet) support [ethtool --set-eee/show-eee]
3) Coalescing configuration support for VFs [via ethtool -c/C]

Please consider applying this to "net-next"

Thanks,
Manish

Manish Chopra (2):
  qede: Add getter APIs support for RX flow classification
  qed/qede: Add setter APIs support for RX flow classification

Rahul Verma (3):
  qed/qede: Add support for vf coalesce configuration.
  qed/qede: Read per queue coalesce from hardware
  qed: Increase per queue max coalesce value.

Sudarsana Reddy Kalluru (2):
  qed: Add support for Energy efficient ethernet.
  qede: Add ethtool support for Energy efficient ethernet.

 drivers/net/ethernet/qlogic/qed/qed_dev.c       | 145 +++++--
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h   |  43 +--
 drivers/net/ethernet/qlogic/qed/qed_hsi.h       |  49 +++
 drivers/net/ethernet/qlogic/qed/qed_l2.c        | 115 ++++++
 drivers/net/ethernet/qlogic/qed/qed_l2.h        |  18 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c      |  58 ++-
 drivers/net/ethernet/qlogic/qed/qed_mcp.c       |  66 ++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h       |  37 +-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c     | 157 ++++++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.h     |   3 +
 drivers/net/ethernet/qlogic/qed/qed_vf.c        |  75 ++++
 drivers/net/ethernet/qlogic/qed/qed_vf.h        |  51 ++-
 drivers/net/ethernet/qlogic/qede/qede.h         |  19 +-
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 205 ++++++++--
 drivers/net/ethernet/qlogic/qede/qede_filter.c  | 483 ++++++++++++++++++++++--
 drivers/net/ethernet/qlogic/qede/qede_main.c    |   9 +-
 include/linux/qed/qed_eth_if.h                  |   1 +
 include/linux/qed/qed_if.h                      |  37 +-
 18 files changed, 1391 insertions(+), 180 deletions(-)

-- 
2.7.2
