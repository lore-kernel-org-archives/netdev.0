From: "Raj, Ashok" <ashok.raj@intel.com>
Subject: Re: [PATCH v9 1/4] PCI: Add new PCIe Fabric End Node flag,
 PCI_DEV_FLAGS_NO_RELAXED_ORDERING
Date: Wed, 9 Aug 2017 11:00:08 -0700
Message-ID: <20170809180007.GA9100@otc-nc-03>
References: <1501917313-9812-1-git-send-email-dingtianhong@huawei.com>
 <1501917313-9812-2-git-send-email-dingtianhong@huawei.com>
 <20170808232200.GO16580@bhelgaas-glaptop.roam.corp.google.com>
 <20170809155841.GA8675@otc-nc-03>
 <MWHPR12MB1600E9D94E74E1DECC192097C88B0@MWHPR12MB1600.namprd12.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bjorn Helgaas <helgaas@kernel.org>,
        Ding Tianhong <dingtianhong@huawei.com>,
        "bhelgaas@google.com" <bhelgaas@google.com>,
        Michael Werner <werner@chelsio.com>,
        Ganesh GR <ganeshgr@chelsio.com>,
        "asit.k.mallick@intel.com" <asit.k.mallick@intel.com>,
        "patrick.j.cramer@intel.com" <patrick.j.cramer@intel.com>,
        "Suravee.Suthikulpanit@amd.com" <Suravee.Suthikulpanit@amd.com>,
        "Bob.Shaw@amd.com" <Bob.Shaw@amd.com>,
        "l.stach@pengutronix.de" <l.stach@pengutronix.de>,
        "amira@mellanox.com" <amira@mellanox.com>,
        "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
        "David.Laight@aculab.com" <David.Laight@aculab.com>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
        "will.deacon@arm.com" <will.deacon@arm.com>
To: Casey Leedom <leedom@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <MWHPR12MB1600E9D94E74E1DECC192097C88B0@MWHPR12MB1600.namprd12.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2017 at 04:46:07PM +0000, Casey Leedom wrote:
> | From: Raj, Ashok <ashok.raj@intel.com>
> | Sent: Wednesday, August 9, 2017 8:58 AM
> | ...
> | As Casey pointed out in an earlier thread, we choose the heavy hammer
> | approach because there are some that can lead to data-corruption as opposed
> | to perf degradation.
> 
> Careful.  As far as I'm aware, there is no Data Corruption problem
> whatsoever with Intel Root Ports and processing of Transaction Layer Packets
> with and without the Relaxed Ordering Attribute set.

That's right.. no data-corruption on Intel parts :-).. It was with
other vendor. Only performance issue with intel root-ports in the parts
identified by the optimization guide. 

Cheers,
AShok
