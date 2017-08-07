From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v9 0/4] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Mon, 7 Aug 2017 12:13:17 +0800
Message-ID: <588b378c-249a-36b0-8890-769258fbb708@huawei.com>
References: <1501917313-9812-1-git-send-email-dingtianhong@huawei.com>
 <20170806.204744.1934067595236180060.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <leedom@chelsio.com>, <ashok.raj@intel.com>, <werner@chelsio.com>,
        <ganeshgr@chelsio.com>, <asit.k.mallick@intel.com>,
        <patrick.j.cramer@intel.com>, <Suravee.Suthikulpanit@amd.com>,
        <Bob.Shaw@amd.com>, <l.stach@pengutronix.de>, <amira@mellanox.com>,
        <gabriele.paoloni@huawei.com>, <David.Laight@aculab.com>,
        <jeffrey.t.kirsher@intel.com>, <catalin.marinas@arm.com>,
        <will.deacon@arm.com>, <mark.rutland@arm.com>,
        <robin.murphy@arm.com>, <alexander.duyck@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>
To: David Miller <davem@davemloft.net>, <bhelgaas@google.com>,
        <helgaas@kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170806.204744.1934067595236180060.davem@davemloft.net>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017/8/7 11:47, David Miller wrote:
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Sat, 5 Aug 2017 15:15:09 +0800
> 
>> Some devices have problems with Transaction Layer Packets with the Relaxed
>> Ordering Attribute set.  This patch set adds a new PCIe Device Flag,
>> PCI_DEV_FLAGS_NO_RELAXED_ORDERING, a set of PCI Quirks to catch some known
>> devices with Relaxed Ordering issues, and a use of this new flag by the
>> cxgb4 driver to avoid using Relaxed Ordering with problematic Root Complex
>> Ports.
>>
>> It's been years since I've submitted kernel.org patches, I appolgise for the
>> almost certain submission errors.
> 
> Which tree should merge this?  The PCI tree or my networking tree?
> 

Hi David：

I think networking tree merge it is a better choice, as it mainly used to tell the NIC
drivers how to use the Relaxed Ordering Attribute, and later we need send patch to enable
RO for ixgbe driver base on this patch. But I am not sure whether Bjorn has some of his own
view. :)

Hi Bjorn:

Could you help review this patch or give some feedback ?

Thanks
Ding
> .
> 
