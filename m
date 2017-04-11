From: Christoph Hellwig <hch@lst.de>
Subject: remove pci_enable_msix() V3
Date: Tue, 11 Apr 2017 13:01:20 +0200
Message-ID: <20170411110125.3446-1-hch@lst.de>
Cc: bhelgaas@google.com, netanel@annapurnalabs.com, jcliburn@gmail.com,
        chris.snook@gmail.com, sgoutham@cavium.com, rric@kernel.org,
        jiri@mellanox.com, idosch@mellanox.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

this series removes the remaining callers of the pci_enable_msix()
function and then the function itself.  The final removal has been
Acked by Bjorn.

Changes since V2:
 - add another patch on Dave's request
 - add various acks
 - spelling fixes in the commit logs

Changes since V1:
 - replace the two previous thunderx patches with a new one from Thanneeru
