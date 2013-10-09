From: Mark Lord <kernel@start.ca>
Subject: Re: [PATCH RFC 00/77] Re-design MSI/MSI-X interrupts enablement pattern
Date: Tue, 08 Oct 2013 21:55:26 -0400
Message-ID: <5254B78E.3020009@start.ca>
References: <cover.1380703262.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Bjorn Helgaas <bhelgaas@google.com>,
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
	VMware@dhcp-26-207.brq.redhat.com, "Inc." <pv-drive
To: Alexander Gordeev <agordeev@redhat.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <cover.1380703262.git.agordeev@redhat.com>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13-10-02 06:29 AM, Alexander Gordeev wrote:
..
> This update converts pci_enable_msix() and pci_enable_msi_block()
> interfaces to canonical kernel functions and makes them return a
> error code in case of failure or 0 in case of success.

Rather than silently break dozens of drivers in mysterious ways,
please invent new function names for the replacements to the
existing pci_enable_msix() and pci_enable_msi_block() functions.

That way, both in-tree and out-of-tree drivers will notice the API change,
rather than having it go unseen and just failing for unknown reasons.

Thanks.
