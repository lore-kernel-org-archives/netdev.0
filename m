From: Mason <slash.tmp@free.fr>
Subject: Legacy features in PCI Express devices
Date: Mon, 13 Mar 2017 17:10:57 +0100
Message-ID: <ef5c9778-fbae-9f4f-ac2e-29b8597537a5@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Bjorn Helgaas <helgaas@kernel.org>,
        David Laight <david.laight@aculab.com>,
        Robin Murphy <robin.murphy@arm.com>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Phuong Nguyen <phuong_nguyen@sigmadesigns.com>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        netdev <netdev@vger.kernel.org>,
        Tim Harvey <tharvey@gateworks.com>,
        Arnd Bergmann <arnd@arndb.de>
To: linux-pci <linux-pci@vger.kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

There are two revisions of our PCI Express controller.

Rev 1 did not support the following features:

  1) legacy PCI interrupt delivery (INTx signals)
  2) I/O address space

Internally, someone stated that such missing support would prevent
some PCIe cards from working with our controller.

Are there really modern PCIe cards that require 1) and/or 2)
to function?

Can someone provide examples of such cards, so that I may test them
on both revisions?

I was told to check ath9k-based cards. Any other examples?

Looking around, I came across this thread:
http://lists.infradead.org/pipermail/linux-arm-kernel/2016-March/418254.html
"i.MX6 PCIe: Fix imx6_pcie_deassert_core_reset() polarity"

IIUC, although some PCIe boards do support MSI, the driver might not
put in the work to use that infrastructure, and instead reverts to
legacy interrupts. (So it is a SW issue, in a sense.)

Regards.
