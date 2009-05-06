From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/3] pci: update 82576 sr-iov quirk with latest
	device IDs
Date: Wed, 06 May 2009 13:25:42 -0700
Message-ID: <20090506202542.17149.88278.stgit@localhost.localdomain>
References: <20090506202450.17149.18959.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:49609
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753240AbZEFU0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 16:26:05 -0400
In-Reply-To: <20090506202450.17149.18959.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The current quirk doesn't include all 82576 device IDs.  This update
resolves that.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/pci/quirks.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 0254741..c01c119 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -2460,6 +2460,8 @@ static void __devinit quirk_i82576_sriov(struct pci_dev *dev)
 DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10c9, quirk_i82576_sriov);
 DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10e6, quirk_i82576_sriov);
 DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10e7, quirk_i82576_sriov);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x10e8, quirk_i82576_sriov);
+DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, 0x150a, quirk_i82576_sriov);
 
 #endif	/* CONFIG_PCI_IOV */
 

