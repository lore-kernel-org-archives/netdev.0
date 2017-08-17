From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] PCI: fix the return value for the
 pci_find_pcie_root_port()
Date: Wed, 16 Aug 2017 19:42:35 -0700 (PDT)
Message-ID: <20170816.194235.391501463422735735.davem@davemloft.net>
References: <1502936730-7368-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com, ashok.raj@intel.com, bhelgaas@google.com,
        helgaas@kernel.org, werner@chelsio.com, ganeshgr@chelsio.com,
        asit.k.mallick@intel.com, patrick.j.cramer@intel.com,
        Suravee.Suthikulpanit@amd.com, Bob.Shaw@amd.com,
        l.stach@pengutronix.de, amira@mellanox.com,
        gabriele.paoloni@huawei.com, David.Laight@aculab.com,
        jeffrey.t.kirsher@intel.com, catalin.marinas@arm.com,
        will.deacon@arm.com, mark.rutland@arm.com, robin.murphy@arm.com,
        alexander.duyck@gmail.com, eric.dumazet@gmail.com,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com, thierry.reding@gmail.com
To: dingtianhong@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1502936730-7368-1-git-send-email-dingtianhong@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Thu, 17 Aug 2017 10:25:30 +0800

> The pci_find_pcie_root_port() would return NULL if the given
> dev is already a Root Port, it looks like unfriendly to the
> PCIe Root Port device, Thierry and Bjorn suggest to let this
> function return the given dev under this circumstances.
> 
> Fixes: 0e405232871d6 ("PCI: fix oops when try to find Root Port for a PCI device")
> Suggested-by: Thierry Reding <thierry.reding@gmail.com>
> Suggested-by: Bjorn Helgaas <helgaas@kernel.org>
> Signed-off-by: Thierry Reding <thierry.reding@gmail.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Bjorn, please review and ACK so Linus doesn't rip my head off again
:-)

Thanks.
