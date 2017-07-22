From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v7 2/3] PCI: Enable PCIe Relaxed Ordering if supported
Date: Sat, 22 Jul 2017 12:19:38 +0800
Message-ID: <5f9b8bfb-41a8-a17c-6fea-581aec1d5573@huawei.com>
References: <1499955692-26556-1-git-send-email-dingtianhong@huawei.com>
 <1499955692-26556-3-git-send-email-dingtianhong@huawei.com>
 <e496ff1d-b836-ebef-fdf7-76273aaaaef6@codeaurora.org>
 <0260e398-bd8e-6615-6d5c-1f7c07b6fc09@huawei.com>
 <67be791f-e0cf-8284-9229-17174dc741ef@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Sinan Kaya <okaya@codeaurora.org>, <leedom@chelsio.com>,
        <ashok.raj@intel.com>, <bhelgaas@google.com>, <helgaas@kernel.org>,
        <werner@chelsio.com>, <ganeshgr@chelsio.com>,
        <asit.k.mallick@intel.com>, <patrick.j.cramer@intel.com>,
        <Suravee.Suthikulpanit@amd.com>, <Bob.Shaw@amd.com>,
        <l.stach@pengutronix.de>, <amira@mellanox.com>,
        <gabriele.paoloni@huawei.com>, <David.Laight@aculab.com>,
        <jeffrey.t.kirsher@intel.com>, <catalin.marinas@arm.com>,
        <will.deacon@arm.com>, <mark.rutland@arm.com>,
        <robin.murphy@arm.com>, <davem@davemloft.net>,
        <alexander.duyck@gmail.com>,
        <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-pci@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <67be791f-e0cf-8284-9229-17174dc741ef@codeaurora.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sinan, Bjorn:

On 2017/7/14 21:54, Sinan Kaya wrote:
> On 7/13/2017 9:26 PM, Ding Tianhong wrote:
>> There is no code to enable the PCIe Relaxed Ordering bit in the configuration space,
>> it is only be enable by default according to the PCIe Standard Specification, what we
>> do is to distinguish the RC problematic platform and clear the Relaxed Ordering bit
>> to tell the PCIe EP don't send any TLPs with Relaxed Ordering Attributes to the Root
>> Complex.
> 
> Maybe, you should change the patch commit as 
> "Disable PCIe Relaxed Ordering if not supported"...

I agree that to use the new commit title as your suggested, thanks. :)

@Bjorn do you want me to spawn a new patchset with the new commit title
and the Reviewed-by from Casey on the patch 3, or maybe you could pick this
up and modify it own ? thanks.

Ding

> 
