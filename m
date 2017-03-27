From: 'Christoph Hellwig' <hch@lst.de>
Subject: Re: [PATCH 5/5] PCI: remove pci_enable_msix
Date: Mon, 27 Mar 2017 16:51:35 +0200
Message-ID: <20170327145135.GA24857@lst.de>
References: <20170327082936.6830-1-hch@lst.de> <20170327082936.6830-6-hch@lst.de> <063D6719AE5E284EB5DD2968C1650D6DCFFBAAD0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Christoph Hellwig' <hch@lst.de>,
        "bhelgaas@google.com" <bhelgaas@google.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netanel@annapurnalabs.com" <netanel@annapurnalabs.com>,
        "jcliburn@gmail.com" <jcliburn@gmail.com>,
        "chris.snook@gmail.com" <chris.snook@gmail.com>,
        "sgoutham@cavium.com" <sgoutham@cavium.com>,
        "rric@kernel.org" <rric@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DCFFBAAD0@AcuExch.aculab.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 27, 2017 at 02:06:45PM +0000, David Laight wrote:
> Apart from all the 'out of tree' drivers that will need
> fixing and a conditional compile added.

That has never been a reason for stopping linux kernel changes.

Never mind that your out of tree drivers should probably never have used
this function anyway, but pci_enable_msix_{exact,range} which would have
been the better choice even before pci_alloc_irq_vectors.
