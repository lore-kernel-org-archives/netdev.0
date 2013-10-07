From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RFC 00/77] Re-design MSI/MSI-X interrupts enablement
 pattern
Date: Mon, 7 Oct 2013 14:21:17 -0400
Message-ID: <20131007182117.GC27396@htj.dyndns.org>
References: <cover.1380703262.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Michael Ellerman <michael@ellerman.id.au>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Andy King <acking@vmware.com>, Jon Mason <jon.mason@intel.com>,
	Matt Porter <mporter@kernel.crashing.org>,
	linux-pci@vger.kernel.org, linux-mips@linux-mips.org,
	linuxppc-dev@lists.ozlabs.org, linux390@de.ibm.com,
	linux-s390@vger.kernel.org, x86@kernel.org,
	linux-ide@vger.kernel.org, iss_storagedev@hp.com,
	linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	linux-driver@qlogic.com,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	"VMware, Inc." <pv-drivers@vmware.com>, linux-sc
To: Alexander Gordeev <agordeev@redhat.com>
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1380703262.git.agordeev@redhat.com>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Alexander.

On Wed, Oct 02, 2013 at 12:48:16PM +0200, Alexander Gordeev wrote:
> Alexander Gordeev (77):
>   PCI/MSI: Fix return value when populate_msi_sysfs() failed
>   PCI/MSI/PPC: Fix wrong RTAS error code reporting
>   PCI/MSI/s390: Fix single MSI only check
>   PCI/MSI/s390: Remove superfluous check of MSI type
>   PCI/MSI: Convert pci_msix_table_size() to a public interface
>   PCI/MSI: Factor out pci_get_msi_cap() interface
>   PCI/MSI: Re-design MSI/MSI-X interrupts enablement pattern
>   PCI/MSI: Get rid of pci_enable_msi_block_auto() interface
>   ahci: Update MSI/MSI-X interrupts enablement code
>   ahci: Check MRSM bit when multiple MSIs enabled
...

Whee.... that's a lot more than I expected.  I was just scanning
multiple msi users.  Maybe we can stage the work in more manageable
steps so that you don't have to go through massive conversion only to
do it all over again afterwards and likewise people don't get
bombarded on each iteration?  Maybe we can first update pci / msi code
proper, msi and then msix?

Thanks.

-- 
tejun
