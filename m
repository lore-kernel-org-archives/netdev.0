From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI to the
 Hisilicon RoCE Driver
Date: Mon, 5 Sep 2016 12:53:07 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F91A6F9F0D@lhreml503-mbx>
References: <1471985090-202472-1-git-send-email-salil.mehta@huawei.com>
 <20160824.215341.1803699371957253329.davem@davemloft.net>
 <d71edae9-805a-2000-9afa-7e8002bc498a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Huwei (Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        oulijun <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linuxarm <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <d71edae9-805a-2000-9afa-7e8002bc498a-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Doug Ledford [mailto:dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org]
> Sent: Thursday, August 25, 2016 12:57 PM
> To: David Miller; Salil Mehta
> Cc: Huwei (Xavier); oulijun; Zhuangyuzeng (Yisen);
> mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Linuxarm
> Subject: Re: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI to
> the Hisilicon RoCE Driver
> 
> On 8/25/2016 12:53 AM, David Miller wrote:
> > From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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
Hi David,
There is a patch in net-next for HNS Ethernet driver which has been accepted.
"b3dc935 net: hns: remove redundant dev_err call in hns_dsaf_get_cfg()"

This patch is creating conflict with Doug Ledford's hns-roce branch. Internally,
We have decided to let all the HNS patches pass through the hns-roce for 4.9
Merge window to facilitate non-conflict merge of pending RoCE driver by Doug Ledford.

Though, we are trying to take a grip of the process for this merge window but
Somehow this one bypassed the internal process. This will create problems for
Hns-roce during merge later this window. Can I request you to drop this patch
For now. We shall re-submit this patch later when things have been settled at
the RoCE/RDMA end or would come again to you through hns-roce branch.

Please let me know if this is possible this time. Thanks in anticipation!

Best regards
Salil

> --
> Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>     GPG Key ID: 0E572FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
