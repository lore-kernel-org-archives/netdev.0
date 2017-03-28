From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 5/5] PCI: remove pci_enable_msix
Date: Tue, 28 Mar 2017 08:41:48 +0200
Message-ID: <20170328064148.GA20271@lst.de>
References: <20170327082936.6830-1-hch@lst.de> <20170327082936.6830-6-hch@lst.de> <83f97789-0817-7549-bfa9-1f8dcb0c26d9@gmail.com> <20170327171148.GB28815@lst.de> <1eaa46ad-9890-c738-3a85-6468161284ba@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, bhelgaas@google.com,
        davem@davemloft.net, netanel@annapurnalabs.com, jcliburn@gmail.com,
        chris.snook@gmail.com, sgoutham@cavium.com, rric@kernel.org,
        netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: David Daney <ddaney.cavm@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1eaa46ad-9890-c738-3a85-6468161284ba@gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 27, 2017 at 10:30:46AM -0700, David Daney wrote:
>> Use pci_enable_msix_{exact,range} for now, as I told you before.
>>
>
> That still results in twice as many MSI-X being provisioned than are needed.

How so?  Except for the return value, a pci_enable_msix_exact call with the
same arguments as your previous pci_enable_msix will work exactly the
same.
