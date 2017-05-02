From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH 0/2] Add new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
Date: Tue, 2 May 2017 08:56:41 +0800
Message-ID: <187e33fe-2c61-076f-7ce8-53b6e900414e@huawei.com>
References: <cover.1493678834.git.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Michael Werner <werner@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>,
        Arjun V <arjun@chelsio.com>,
        David Miller <davem@davemloft.com>,
        "Asit K Mallick" <asit.k.mallick@intel.com>,
        Patrick J Cramer <patrick.j.cramer@intel.com>,
        Ashok Raj <ashok.raj@intel.com>,
        "Suravee Suthikulpanit" <Suravee.Suthikulpanit@amd.com>,
        Bob Shaw <Bob.Shaw@amd.com>, h <l.stach@pengutronix.de>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        "Mark Rutland" <mark.rutland@arm.com>,
        Amir Ancel <amira@mellanox.com>,
        "Gabriele Paoloni" <gabriele.paoloni@huawei.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        LinuxArm <linuxarm@huawei.com>,
        David Laight <David.Laight@aculab.com>,
        <jeffrey.t.kirsher@intel.com>, <netdev@vger.kernel.org>,
To: Casey Leedom <leedom@chelsio.com>,
        Bjorn Helgaas <helgaas@kernel.org>, <leedom@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([45.249.212.189]:5903 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750954AbdEBA5e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 20:57:34 -0400
In-Reply-To: <cover.1493678834.git.leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Casey:

This solution looks good to me, I will test this for ixgbe.:)

Thanks
Ding

On 2017/5/2 7:13, Casey Leedom wrote:
> Some devices have problems with Transaction Layer Packets with the Relaxed
> Ordering Attribute set.  This patch set adds a new PCIe Device Flag,
> PCI_DEV_FLAGS_NO_RELAXED_ORDERING, a set of PCI Quirks to catch some known
> devices with Relaxed Ordering issues, and a use of this new flag by the
> cxgb4 driver to avoid using Relaxed Ordering with problematic Root Complex
> Ports.
> 
> It's been years since I've submitted kernel.org patches, I appolgise for the
> almost certain submission errors.
> 
> Casey Leedom (2):
>   PCI: Add new PCIe Fabric End Node flag,
>     PCI_DEV_FLAGS_NO_RELAXED_ORDERING
>   net/cxgb4: Use new PCI_DEV_FLAGS_NO_RELAXED_ORDERING flag
> 
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  1 +
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 17 +++++++++++
>  drivers/net/ethernet/chelsio/cxgb4/sge.c        |  5 ++--
>  drivers/pci/quirks.c                            | 38 +++++++++++++++++++++++++
>  include/linux/pci.h                             |  2 ++
>  5 files changed, 61 insertions(+), 2 deletions(-)
> 
