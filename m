From: Manish Chopra <manish.chopra@cavium.com>
Subject: [PATCH net-next 0/6] qed/qede: VF tunnelling support
Date: Mon, 24 Apr 2017 10:00:43 -0700
Message-ID: <20170424170049.16027-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0061.outbound.protection.outlook.com ([104.47.32.61]:33699
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S975226AbdDXRBU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 13:01:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

With this series VFs can run vxlan/geneve/gre tunnels over it.
Please consider applying this series to "net-next"

Thanks,
Manish

Manish Chopra (6):
  qed: refactor tunnelling - API/Structs
  qed/qede: Enable tunnel offloads based on hw configuration
  qede: Disable tunnel offloads for non offloaded UDP ports
  qede: Configure UDP ports in local context.
  qed/qede: Add UDP ports in bulletin board
  qed - VF tunnelling support [VXLAN/GENEVE/GRE]

 drivers/net/ethernet/qlogic/qed/qed.h             |  31 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c         |  17 +-
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h     |   2 +-
 drivers/net/ethernet/qlogic/qed/qed_l2.c          |  37 ++-
 drivers/net/ethernet/qlogic/qed/qed_main.c        |  47 ++-
 drivers/net/ethernet/qlogic/qed/qed_sp.h          |   4 +-
 drivers/net/ethernet/qlogic/qed/qed_sp_commands.c | 330 +++++++++++-----------
 drivers/net/ethernet/qlogic/qed/qed_sriov.c       | 240 ++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.h       |   9 +
 drivers/net/ethernet/qlogic/qed/qed_vf.c          | 165 +++++++++++
 drivers/net/ethernet/qlogic/qed/qed_vf.h          |  58 +++-
 drivers/net/ethernet/qlogic/qede/qede.h           |   3 +-
 drivers/net/ethernet/qlogic/qede/qede_filter.c    |  84 +++++-
 drivers/net/ethernet/qlogic/qede/qede_fp.c        |  23 +-
 drivers/net/ethernet/qlogic/qede/qede_main.c      |  56 ++--
 include/linux/qed/qed_eth_if.h                    |   1 +
 include/linux/qed/qed_if.h                        |   5 +
 17 files changed, 857 insertions(+), 255 deletions(-)

-- 
2.7.2
