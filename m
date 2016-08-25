From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI to the
 Hisilicon RoCE Driver
Date: Thu, 25 Aug 2016 12:08:05 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F91A6E813F@lhreml503-mbx>
References: <1471985090-202472-1-git-send-email-salil.mehta@huawei.com>
 <20160824.215341.1803699371957253329.davem@davemloft.net>
 <d71edae9-805a-2000-9afa-7e8002bc498a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Huwei (Xavier)" <xavier.huwei@huawei.com>,
        oulijun <oulijun@huawei.com>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Doug Ledford <dledford@redhat.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d71edae9-805a-2000-9afa-7e8002bc498a@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Doug Ledford [mailto:dledford@redhat.com]
> Sent: Thursday, August 25, 2016 12:57 PM
> To: David Miller; Salil Mehta
> Cc: Huwei (Xavier); oulijun; Zhuangyuzeng (Yisen);
> mehta.salil.lnk@gmail.com; linux-rdma@vger.kernel.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI to
> the Hisilicon RoCE Driver
> 
> On 8/25/2016 12:53 AM, David Miller wrote:
> > From: Salil Mehta <salil.mehta@huawei.com>
> > Date: Wed, 24 Aug 2016 04:44:48 +0800
> >
> >> This patch is meant to add support of ACPI to the Hisilicon RoCE
> driver.
> >> Following changes have been made in the driver(s):
> >>
> >> Patch 1/2: HNS Ethernet Driver: changes to support ACPI have been
> done in
> >>    the RoCE reset function part of the HNS ethernet driver. Earlier
> it only
> >>    supported DT/syscon.
> >>
> >> Patch 2/2. HNS RoCE driver: changes done in RoCE driver are meant to
> detect
> >>    the type and then either use DT specific or ACPI spcific
> functions. Where
> >>    ever possible, this patch tries to make use of "Unified Device
> Property
> >>    Interface" APIs to support both DT and ACPI through single
> interface.
> >>
> >> NOTE 1: ACPI changes done in both of the drivers depend upon the
> ACPI Table
> >>      (DSDT and IORT tables) changes part of UEFI/BIOS. These changes
> are NOT
> >>      part of this patch-set.
> >> NOTE 2: Reset function in Patch 1/2 depends upon the reset function
> added in
> >>      ACPI tables(basically DSDT table) part of the UEFI/BIOS. Again,
> this
> >>      change is NOT reflected in this patch-set.
> >
> > I can't apply this series to my tree because the hns infiniband
> driver
> > doesn't exist in it.
> >
> 
> No.  This probably needs to go through my tree.  Although with all of
> the requirements, I'm a bit concerned about those being present
> elsewhere.
> 
> --
> Doug Ledford <dledford@redhat.com>
>     GPG Key ID: 0E572FDD
Hello Doug,
Thanks for your reply. I have just replied to David email as well and did
not realize your response was already on the way. Sorry for this!

I would just like to request, if by any chance, we can expedite the acceptance
of the below patch (part of patch-set) in the net-next. This might help you as
well in future when you will actually push the RoCE driver to the linux-next.

"[PATCH for-next 1/2] net: hns: Add support of ACPI to HNS driver RoCE Reset
 function"

Below HNS RoCE reset function patch has already been accepted by Dave Miller and
is part of net-next,
https://patchwork.kernel.org/patch/9287497/

Also, above ACPI support of RoCE Reset patch cleanly applies over the already
accepted patch in the link and is not dependent on other accompanying RoCE
driver ACPI changes or even the presence of the Infiniband/RoCE Driver in the
net-next repository.

Could you please suggest if this the something which can be considered?   

Thanks in anticipation
Salil Mehta
