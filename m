From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 5/5] PCI: remove pci_enable_msix
Date: Mon, 27 Mar 2017 15:03:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFBAC3E@AcuExch.aculab.com>
References: <20170327082936.6830-1-hch@lst.de>
 <20170327082936.6830-6-hch@lst.de>
 <063D6719AE5E284EB5DD2968C1650D6DCFFBAAD0@AcuExch.aculab.com>
 <20170327145135.GA24857@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netanel@annapurnalabs.com" <netanel@annapurnalabs.com>,
        "jcliburn@gmail.com" <jcliburn@gmail.com>,
        "chris.snook@gmail.com" <chris.snook@gmail.com>,
        "sgoutham@cavium.com" <sgoutham@cavium.com>,
        "rric@kernel.org" <rric@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: 'Christoph Hellwig' <hch@lst.de>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170327145135.GA24857@lst.de>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: 'Christoph Hellwig'
> Sent: 27 March 2017 15:52
> On Mon, Mar 27, 2017 at 02:06:45PM +0000, David Laight wrote:
> > Apart from all the 'out of tree' drivers that will need
> > fixing and a conditional compile added.
> 
> That has never been a reason for stopping linux kernel changes.

I'm aware of that, but sometimes you just make life hard.

> Never mind that your out of tree drivers should probably never have used
> this function anyway, but pci_enable_msix_{exact,range} which would have
> been the better choice even before pci_alloc_irq_vectors.

Indeed, but pci_enable_msix_range() only appeared in 3.14.
We have to support a wide range of kernels.
I think we've finally managed to get most of our customers off 2.6.18.

	David
