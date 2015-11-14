From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 0/9] constify pci_error_handlers structures
Date: Sat, 14 Nov 2015 11:06:52 +0100
Message-ID: <1447495621-9161-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	qat-linux@intel.com, linux-crypto@vger.kernel.org,
	kvm@vger.kernel.org
To: MPT-FusionLinux.pdl@avagotech.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Constify never-modified pci_error_handlers structures.

---

 drivers/crypto/qat/qat_common/adf_aer.c         |    2 +-
 drivers/misc/genwqe/card_base.c                 |    2 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c |    2 +-
 drivers/net/ethernet/sfc/efx.c                  |    2 +-
 drivers/scsi/be2iscsi/be_main.c                 |    2 +-
 drivers/scsi/bfa/bfad.c                         |    2 +-
 drivers/scsi/csiostor/csio_init.c               |    2 +-
 drivers/scsi/mpt3sas/mpt3sas_scsih.c            |    2 +-
 drivers/vfio/pci/vfio_pci.c                     |    2 +-
 9 files changed, 9 insertions(+), 9 deletions(-)
