From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI to the
 Hisilicon RoCE Driver
Date: Wed, 24 Aug 2016 21:53:41 -0700 (PDT)
Message-ID: <20160824.215341.1803699371957253329.davem@davemloft.net>
References: <1471985090-202472-1-git-send-email-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford@redhat.com, xavier.huwei@huawei.com, oulijun@huawei.com,
        yisen.zhuang@huawei.com, mehta.salil.lnk@gmail.com,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: salil.mehta@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471985090-202472-1-git-send-email-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Salil Mehta <salil.mehta@huawei.com>
Date: Wed, 24 Aug 2016 04:44:48 +0800

> This patch is meant to add support of ACPI to the Hisilicon RoCE driver.
> Following changes have been made in the driver(s):
> 
> Patch 1/2: HNS Ethernet Driver: changes to support ACPI have been done in
>    the RoCE reset function part of the HNS ethernet driver. Earlier it only
>    supported DT/syscon.
> 
> Patch 2/2. HNS RoCE driver: changes done in RoCE driver are meant to detect
>    the type and then either use DT specific or ACPI spcific functions. Where
>    ever possible, this patch tries to make use of "Unified Device Property
>    Interface" APIs to support both DT and ACPI through single interface.
> 
> NOTE 1: ACPI changes done in both of the drivers depend upon the ACPI Table
>      (DSDT and IORT tables) changes part of UEFI/BIOS. These changes are NOT
>      part of this patch-set.
> NOTE 2: Reset function in Patch 1/2 depends upon the reset function added in
>      ACPI tables(basically DSDT table) part of the UEFI/BIOS. Again, this
>      change is NOT reflected in this patch-set.

I can't apply this series to my tree because the hns infiniband driver
doesn't exist in it.
