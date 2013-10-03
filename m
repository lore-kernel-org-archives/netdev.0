From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH RFC 46/77] mlx4: Update MSI/MSI-X interrupts enablement
 code
Date: Thu, 3 Oct 2013 11:39:32 +0300
Message-ID: <20131003113932.065b9b63@jpm-OptiPlex-GX620>
References: <cover.1380703262.git.agordeev@redhat.com>
	<b0a9f6f455aa03b7769e6d9cc2e7fdbc06732b2f.1380703263.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Bjorn Helgaas <bhelgaas@google.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Michael Ellerman <michael@ellerman.id.au>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>,
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
	"VMware, Inc." <pv-dr
To: Alexander Gordeev <agordeev@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <b0a9f6f455aa03b7769e6d9cc2e7fdbc06732b2f.1380703263.git.agordeev@redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed,  2 Oct 2013 12:49:02 +0200
Alexander Gordeev <agordeev@redhat.com> wrote:

> As result of recent re-design of the MSI/MSI-X interrupts enabling
> pattern this driver has to be updated to use the new technique to
> obtain a optimal number of MSI/MSI-X interrupts required.
> 
> Signed-off-by: Alexander Gordeev <agordeev@redhat.com>

New review -- ACK (i.e., patch is OK), subject to acceptance of patches
05 and 07 of this patch set.

I sent my previous review (NACK) when I was not yet aware that
changes proposed were due to the two earlier patches (mentioned above)
in the current patch set.

The change log here should actually read something like the following:

As a result of changes to the MSI/MSI_X enabling procedures, this driver
must be modified in order to preserve its current msi/msi_x enablement
logic.

-Jack
