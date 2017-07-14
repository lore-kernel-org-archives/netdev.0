From: Sinan Kaya <okaya@codeaurora.org>
Subject: Re: [PATCH v7 2/3] PCI: Enable PCIe Relaxed Ordering if supported
Date: Fri, 14 Jul 2017 09:54:45 -0400
Message-ID: <67be791f-e0cf-8284-9229-17174dc741ef@codeaurora.org>
References: <1499955692-26556-1-git-send-email-dingtianhong@huawei.com>
 <1499955692-26556-3-git-send-email-dingtianhong@huawei.com>
 <e496ff1d-b836-ebef-fdf7-76273aaaaef6@codeaurora.org>
 <0260e398-bd8e-6615-6d5c-1f7c07b6fc09@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Ding Tianhong <dingtianhong@huawei.com>, leedom@chelsio.com,
        ashok.raj@intel.com, bhelgaas@google.com, helgaas@kernel.org,
        werner@chelsio.com, ganeshgr@chelsio.com, asit.k.mallick@intel.com,
        patrick.j.cramer@intel.com, Suravee.Suthikulpanit@amd.com,
        Bob.Shaw@amd.com, l.stach@pengutronix.de, amira@mellanox.com,
        gabriele.paoloni@huawei.com, David.Laight@aculab.com,
        jeffrey.t.kirsher@intel.com, catalin.marinas@arm.com,
        will.deacon@arm.com, mark.rutland@arm.com, robin.murphy@arm.com,
        davem@davemloft.net, alexander.duyck@gmail.com,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0260e398-bd8e-6615-6d5c-1f7c07b6fc09@huawei.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/13/2017 9:26 PM, Ding Tianhong wrote:
> There is no code to enable the PCIe Relaxed Ordering bit in the configuration space,
> it is only be enable by default according to the PCIe Standard Specification, what we
> do is to distinguish the RC problematic platform and clear the Relaxed Ordering bit
> to tell the PCIe EP don't send any TLPs with Relaxed Ordering Attributes to the Root
> Complex.

Maybe, you should change the patch commit as 
"Disable PCIe Relaxed Ordering if not supported"...

-- 
Sinan Kaya
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the Code Aurora Forum, a Linux Foundation Collaborative Project.
