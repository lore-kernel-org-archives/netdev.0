From: Christoph Hellwig <hch@lst.de>
Subject: remove pci_enable_msix()
Date: Mon, 27 Mar 2017 10:29:31 +0200
Message-ID: <20170327082936.6830-1-hch@lst.de>
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: bhelgaas@google.com, davem@davemloft.net,
        netanel@annapurnalabs.com, jcliburn@gmail.com,
        chris.snook@gmail.com, sgoutham@cavium.com, rric@kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

this series removes the remaining callers of the pci_enable_msix()
function and then the function itself.  All remaining users in in network
drivers, so if Bjorn is fine with it I'd like to handle it entirely
through the netdev tree.
