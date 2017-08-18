From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] PCI: Allow PCI express root ports to find themselves
Date: Fri, 18 Aug 2017 14:32:36 +1000
Message-ID: <87bmndqyvv.fsf@concordia.ellerman.id.au>
References: <1502936730-7368-1-git-send-email-dingtianhong@huawei.com> <20170817110614.11454-1-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: leedom@chelsio.com, ashok.raj@intel.com, werner@chelsio.com,
        ganeshgr@chelsio.com, asit.k.mallick@intel.com,
        patrick.j.cramer@intel.com, Suravee.Suthikulpanit@amd.com,
        Bob.Shaw@amd.com, l.stach@pengutronix.de, amira@mellanox.com,
        gabriele.paoloni@huawei.com, David.Laight@aculab.com,
        jeffrey.t.kirsher@intel.com, catalin.marinas@arm.com,
        will.deacon@arm.com, mark.rutland@arm.com, robin.murphy@arm.com,
        alexander.duyck@gmail.com, eric.dumazet@gmail.com,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com
To: Thierry Reding <thierry.reding@gmail.com>,
        David Miller <davem@davemloft.net>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Ding Tianhong <dingtianhong@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170817110614.11454-1-thierry.reding@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thierry Reding <thierry.reding@gmail.com> writes:

> From: Thierry Reding <treding@nvidia.com>
>
> If the pci_find_pcie_root_port() function is called on a root port
> itself, return the root port rather than NULL.
>
> This effectively reverts commit 0e405232871d6 ("PCI: fix oops when
> try to find Root Port for a PCI device") which added an extra check
> that would now be redundant.
>
> Fixes: a99b646afa8a ("PCI: Disable PCIe Relaxed Ordering if unsupported")
> Fixes: c56d4450eb68 ("PCI: Turn off Request Attributes to avoid Chelsio T5 Completion erratum")
> Signed-off-by: Thierry Reding <treding@nvidia.com>
> ---
> This applies on top of and was tested on next-20170817.
>
> Michael, it'd be great if you could test this one again to clarify
> whether or not the fix that's already in Linus' tree is still needed, or
> whether it's indeed obsoleted by this patch.

This works fine for me, applied on top of Linus' tree (d33a2a914319).

cheers
