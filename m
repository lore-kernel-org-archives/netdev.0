From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 00/10] Constify isdn pci_device_id's.
Date: Sat, 15 Jul 2017 09:55:41 +0530
Message-ID: <1500092751-8291-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: isdn@linux-pingi.de, davem@davemloft.net, dhowells@redhat.com,
        johannes.berg@intel.com, mac@melware.de, baoyou.xie@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pci_device_id are not supposed to change at runtime. All functions
working with pci_device_id provided by <linux/pci.h> work with
const pci_device_id. So mark the non-const structs as const.

Arvind Yadav (10):
  [PATCH 01/10] isdn: hisax: constify pci_device_id.
  [PATCH 02/10] isdn: hisax: hfc4s8s_l1: constify pci_device_id.
  [PATCH 03/10] isdn: hisax: hisax_fcpcipnp: constify pci_device_id.
  [PATCH 04/10] isdn: eicon: constify pci_device_id.
  [PATCH 05/10] isdn: mISDN: netjet: constify pci_device_id.
  [PATCH 06/10] isdn: mISDN: hfcmulti: constify pci_device_id.
  [PATCH 07/10] isdn: mISDN: w6692: constify pci_device_id.
  [PATCH 08/10] isdn: mISDN: avmfritz: constify pci_device_id.
  [PATCH 09/10] isdn: mISDN: hfcpci: constify pci_device_id.
  [PATCH 10/10] isdn: avm: c4: constify pci_device_id.

 drivers/isdn/hardware/avm/c4.c          | 2 +-
 drivers/isdn/hardware/eicon/divasmain.c | 2 +-
 drivers/isdn/hardware/mISDN/avmfritz.c  | 2 +-
 drivers/isdn/hardware/mISDN/hfcmulti.c  | 2 +-
 drivers/isdn/hardware/mISDN/hfcpci.c    | 2 +-
 drivers/isdn/hardware/mISDN/netjet.c    | 2 +-
 drivers/isdn/hardware/mISDN/w6692.c     | 2 +-
 drivers/isdn/hisax/config.c             | 2 +-
 drivers/isdn/hisax/hfc4s8s_l1.c         | 2 +-
 drivers/isdn/hisax/hisax_fcpcipnp.c     | 2 +-
 10 files changed, 10 insertions(+), 10 deletions(-)

-- 
2.7.4
