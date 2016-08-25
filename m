From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI to the
 Hisilicon RoCE Driver
Date: Thu, 25 Aug 2016 14:50:05 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F91A6E85C2@lhreml503-mbx>
References: <1471985090-202472-1-git-send-email-salil.mehta@huawei.com>
 <20160824.215341.1803699371957253329.davem@davemloft.net>
 <F4CC6FACFEB3C54C9141D49AD221F7F91A6E7FA9@lhreml503-mbx>
 <8fa4e921-9dfc-bf2b-32c9-230136536f65@redhat.com>
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
In-Reply-To: <8fa4e921-9dfc-bf2b-32c9-230136536f65-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Doug Ledford [mailto:dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org]
> Sent: Thursday, August 25, 2016 2:53 PM
> To: Salil Mehta; David Miller
> Cc: Huwei (Xavier); oulijun; Zhuangyuzeng (Yisen);
> mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Linuxarm
> Subject: Re: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI to
> the Hisilicon RoCE Driver
> 
> On 8/25/2016 8:00 AM, Salil Mehta wrote:
> >
> >
> >> -----Original Message-----
> >> From: David Miller [mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org]
> >> Sent: Thursday, August 25, 2016 5:54 AM
> >> To: Salil Mehta
> >> Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; Huwei (Xavier); oulijun; Zhuangyuzeng
> (Yisen);
> >> mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> >> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Linuxarm
> >> Subject: Re: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI
> to
> >> the Hisilicon RoCE Driver
> >>
> >> From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> >> Date: Wed, 24 Aug 2016 04:44:48 +0800
> >>
> >>> This patch is meant to add support of ACPI to the Hisilicon RoCE
> >> driver.
> >>> Following changes have been made in the driver(s):
> >>>
> >>> Patch 1/2: HNS Ethernet Driver: changes to support ACPI have been
> >> done in
> >>>    the RoCE reset function part of the HNS ethernet driver. Earlier
> >> it only
> >>>    supported DT/syscon.
> >>>
> >>> Patch 2/2. HNS RoCE driver: changes done in RoCE driver are meant
> to
> >> detect
> >>>    the type and then either use DT specific or ACPI spcific
> >> functions. Where
> >>>    ever possible, this patch tries to make use of "Unified Device
> >> Property
> >>>    Interface" APIs to support both DT and ACPI through single
> >> interface.
> >>>
> >>> NOTE 1: ACPI changes done in both of the drivers depend upon the
> ACPI
> >> Table
> >>>      (DSDT and IORT tables) changes part of UEFI/BIOS. These
> changes
> >> are NOT
> >>>      part of this patch-set.
> >>> NOTE 2: Reset function in Patch 1/2 depends upon the reset function
> >> added in
> >>>      ACPI tables(basically DSDT table) part of the UEFI/BIOS.
> Again,
> >> this
> >>>      change is NOT reflected in this patch-set.
> >>
> >> I can't apply this series to my tree because the hns infiniband
> driver
> >> doesn't exist in it.
> > Hi David,
> > I understand your point. This patch-set was primarily sent for Doug
> Ledford
> > and is based on his internal repository (which has been rebased on
> the
> > net-next).
> >
> > Though we were hoping, if by any chance, we can expedite the
> acceptance of the
> > below patch part of patch-set in the net-next. This might help Doug
> Ledford as
> > well later on when he pushes the already accepted RoCE driver and
> ACPI patches
> > to linux-next,
> >
> > "[PATCH for-next 1/2] net: hns: Add support of ACPI to HNS driver
> RoCE Reset
> >  function"
> >
> > Below HNS RoCE reset function patch has already been accepted and is
> part of your
> > net-next,
> > https://patchwork.kernel.org/patch/9287497/
> >
> > Above ACPI support of RoCE Reset patch cleanly applies over the
> already accepted
> > patch in the link. It is not dependent on other accompanying RoCE
> driver ACPI
> > changes related patch or even the presence of the Infiniband/RoCE
> Driver in the
> > net-next repository.
> >
> > Could you please suggest anything here?
> >
> > Thanks
> > Salil
> >
> 
> I can take both.  I already pulled net-next to get the initial hns roce
> reset patch from Dave, so these will apply cleanly with my tree and
> merge cleanly with Dave's due to the common ancestral base.  The only
> problem is that if you intend to send any other patches that effect
> this
> code, then they would need to come through me until the 4.9 merge
> window
> is complete so that we don't have later merge conflicts.
Ok sure, I got your point. Yes, there are few patches we need to push in
but are related to RoCE CM(Connection Manager) mode and would follow
soon. There are no further patches we foresee which are for RoCE Driver but are
dependent upon HNS Ethernet driver. 

But kindly note, there could be some patches in development in HNS Ethernet driver
which might sneak in through net-next. These might not be related to RoCE Driver but
might have some common files which might lead to conflict again further down
the line when you try to merge ACPI RoCE reset again. This HNS driver change
is very difficult for us to control since amount of development going on in HNS
is of much higher magnitude than the RoCE as of now. It will be almost impossible
for us to convince internally and shift that entire development being done right
now on net-next and rebase it to your internal hns-roce branch for a month of time
till 4.9. This will affect many features deadlines internally. 

So, if I understood you correctly, this delta (which could be large), when next merge
window open would be taken care by you. And we can expect below to be part of 4.9
1) RoCE Base driver (*Already Accepted*)
2) ACPI changes for RoCE Driver (*if accepted*)
   * ACPI changes for the RoCE Driver
   * ACPI changes for RoCE reset function part of the HNS driver

Please correct my understanding if I am wrong here.

Thanks, again!
Salil Mehta
> 
> --
> Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>     GPG Key ID: 0E572FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
