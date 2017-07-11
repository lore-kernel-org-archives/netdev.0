From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH v2 00/10] Constify attribute_group structures
Date: Tue, 11 Jul 2017 13:04:17 +0530
Message-ID: <1499758458-24920-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: m.grzeschik@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

attribute_groups are not supposed to change at runtime. So mark the
non-const structs as const.

Arvind Yadav (10):
  [PATCH v2 01/10] net: cdc_ncm: constify attribute_group structures.
  [PATCH v2 02/10] net: can: at91_can: constify attribute_group structures.
  [PATCH v2 03/10] net: can: janz-ican3: constify attribute_group structures.
  [PATCH v2 04/10] wireless: ipw2200: constify attribute_group structures.
  [PATCH v2 05/10] wireless: ipw2100: constify attribute_group structures.
  [PATCH v2 06/10] wireless: iwlegacy: constify attribute_group structures.
  [PATCH v2 07/10] wireless: iwlegacy: Constify attribute_group structures.
  [PATCH v2 08/10] arcnet: com20020-pci: constify attribute_group structures.
  [PATCH v2 09/10] net: bonding: constify attribute_group structures.
  [PATCH v2 10/10] net: chelsio: cxgb3: constify attribute_group structures.

 drivers/net/arcnet/com20020-pci.c               | 2 +-
 drivers/net/bonding/bond_sysfs.c                | 2 +-
 drivers/net/can/at91_can.c                      | 2 +-
 drivers/net/can/janz-ican3.c                    | 2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c | 8 ++++++--
 drivers/net/usb/cdc_ncm.c                       | 2 +-
 drivers/net/wireless/intel/ipw2x00/ipw2100.c    | 2 +-
 drivers/net/wireless/intel/ipw2x00/ipw2200.c    | 2 +-
 drivers/net/wireless/intel/iwlegacy/3945-mac.c  | 2 +-
 drivers/net/wireless/intel/iwlegacy/4965-mac.c  | 2 +-
 10 files changed, 15 insertions(+), 11 deletions(-)

-- 
1.9.1
