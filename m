From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 0/4] constify net platform_device_id
Date: Sun, 13 Aug 2017 16:41:44 +0530
Message-ID: <1502622705-11169-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-can@vger.kernel.org
To: wg@grandegger.com, mkl@pengutronix.de, madalin.bucur@nxp.com,
        davem@davemloft.net, sergei.shtylyov@cogentembedded.com,
        grygorii.strashko@ti.com
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

platform_device_id are not supposed to change at runtime. All functions
working with platform_device_id provided by <linux/platform_device.h>
work with const platform_device_id. So mark the non-const structs as const.

Arvind Yadav (4):
  [PATCH 1/4] can: constify platform_device_id
  [PATCH 2/4] net: dpaa_eth: constify platform_device_id
  [PATCH 3/4] net: sh_eth: constify platform_device_id
  [PATCH 4/4] net: ti: cpsw:: constify platform_device_id

 drivers/net/can/c_can/c_can_platform.c         | 2 +-
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 2 +-
 drivers/net/ethernet/renesas/sh_eth.c          | 2 +-
 drivers/net/ethernet/ti/cpsw.c                 | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

-- 
2.7.4

