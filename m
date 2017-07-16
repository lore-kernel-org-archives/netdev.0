From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 00/12] constify atm pci_device_id.
Date: Sun, 16 Jul 2017 15:02:28 +0530
Message-ID: <1500197560-14623-1-git-send-email-arvind.yadav.cs@gmail.com>
To: 3chas3@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        linux-atm-general@lists.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pci_device_id are not supposed to change at runtime. All functions
working with pci_device_id provided by <linux/pci.h> work with
const pci_device_id. So mark the non-const structs as const.

Arvind Yadav (12):
  [PATCH 01/12] atm: iphase: constify pci_device_id.
  [PATCH 02/12] atm: ambassador: constify pci_device_id.
  [PATCH 03/12] atm: fore200e: constify pci_device_id.
  [PATCH 04/12] atm: nicstar: constify pci_device_id.
  [PATCH 05/12] atm: he: constify pci_device_id.
  [PATCH 06/12] atm: horizon: constify pci_device_id.
  [PATCH 07/12] atm: solos-pci: constify pci_device_id.
  [PATCH 08/12] atm: lanai: constify pci_device_id.
  [PATCH 09/12] atm: zatm: constify pci_device_id.
  [PATCH 10/12] atm: firestream: constify pci_device_id.
  [PATCH 11/12] atm: eni: constify pci_device_id.
  [PATCH 12/12] atm: idt77252: constify pci_device_id.

 drivers/atm/ambassador.c | 2 +-
 drivers/atm/eni.c        | 2 +-
 drivers/atm/firestream.c | 2 +-
 drivers/atm/fore200e.c   | 2 +-
 drivers/atm/he.c         | 2 +-
 drivers/atm/horizon.c    | 2 +-
 drivers/atm/idt77252.c   | 2 +-
 drivers/atm/iphase.c     | 2 +-
 drivers/atm/lanai.c      | 2 +-
 drivers/atm/nicstar.c    | 2 +-
 drivers/atm/solos-pci.c  | 2 +-
 drivers/atm/zatm.c       | 2 +-
 12 files changed, 12 insertions(+), 12 deletions(-)

-- 
2.7.4
