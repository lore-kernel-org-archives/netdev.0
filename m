From: Alexander Gordeev <agordeev@redhat.com>
Subject: Re: [PATCH RFC 00/77] Re-design MSI/MSI-X interrupts enablement
 pattern
Date: Tue, 8 Oct 2013 11:07:16 +0200
Message-ID: <20131008090716.GA10561@dhcp-26-207.brq.redhat.com>
References: <cover.1380703262.git.agordeev@redhat.com>
 <20131007182117.GC27396@htj.dyndns.org>
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
        So
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline
In-Reply-To: <20131007182117.GC27396@htj.dyndns.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On Mon, Oct 07, 2013 at 02:21:17PM -0400, Tejun Heo wrote:
> Whee.... that's a lot more than I expected.  I was just scanning
> multiple msi users.  Maybe we can stage the work in more manageable
> steps so that you don't have to go through massive conversion only to
> do it all over again afterwards and likewise people don't get
> bombarded on each iteration?  Maybe we can first update pci / msi code
> proper, msi and then msix?

Multipe MSIs is just a handful of drivers, really. MSI-X impact still
will be huge. But if we opt a different name for the new pci_enable_msix()
then we could first update pci/msi, then drivers (in few stages possibly)
and finally remove the old implementation.

> tejun

-- 
Regards,
Alexander Gordeev
agordeev@redhat.com
