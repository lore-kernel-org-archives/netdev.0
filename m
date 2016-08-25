From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI to the
 Hisilicon RoCE Driver
Date: Thu, 25 Aug 2016 15:34:15 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F91A6E8696@lhreml503-mbx>
References: <1471985090-202472-1-git-send-email-salil.mehta@huawei.com>
 <20160824.215341.1803699371957253329.davem@davemloft.net>
 <F4CC6FACFEB3C54C9141D49AD221F7F91A6E7FA9@lhreml503-mbx>
 <8fa4e921-9dfc-bf2b-32c9-230136536f65@redhat.com>
 <F4CC6FACFEB3C54C9141D49AD221F7F91A6E85C2@lhreml503-mbx>
 <6a3c65b0-500e-c097-7ff4-15ec5f1de19c@redhat.com>
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
In-Reply-To: <6a3c65b0-500e-c097-7ff4-15ec5f1de19c@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Doug Ledford [mailto:dledford@redhat.com]
> Sent: Thursday, August 25, 2016 4:00 PM
> To: Salil Mehta; David Miller
> Cc: Huwei (Xavier); oulijun; Zhuangyuzeng (Yisen);
> mehta.salil.lnk@gmail.com; linux-rdma@vger.kernel.org;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH for-next 0/2] {IB,net}/hns: Add support of ACPI to
> the Hisilicon RoCE Driver
> 
> On 8/25/2016 10:50 AM, Salil Mehta wrote:
> 
> >> I can take both.  I already pulled net-next to get the initial hns
> roce
> >> reset patch from Dave, so these will apply cleanly with my tree and
> >> merge cleanly with Dave's due to the common ancestral base.  The
> only
> >> problem is that if you intend to send any other patches that effect
> >> this
> >> code, then they would need to come through me until the 4.9 merge
> >> window
> >> is complete so that we don't have later merge conflicts.
> > Ok sure, I got your point. Yes, there are few patches we need to push
> in
> > but are related to RoCE CM(Connection Manager) mode and would follow
> > soon. There are no further patches we foresee which are for RoCE
> Driver but are
> > dependent upon HNS Ethernet driver.
> 
> Ok.
> 
> > But kindly note, there could be some patches in development in HNS
> Ethernet driver
> > which might sneak in through net-next. These might not be related to
> RoCE Driver but
> > might have some common files which might lead to conflict again
> further down
> > the line when you try to merge ACPI RoCE reset again. This HNS driver
> change
> > is very difficult for us to control since amount of development going
> on in HNS
> > is of much higher magnitude than the RoCE as of now. It will be
> almost impossible
> > for us to convince internally and shift that entire development being
> done right
> > now on net-next and rebase it to your internal hns-roce branch for a
> month of time
> > till 4.9. This will affect many features deadlines internally.
> 
> This is what Linus wants to avoid.  It's not necessary to shift your
> work from one tree to another, what is needed if for your RoCE team and
> your net team to plan out what you are going to submit for the next
> kernel and provide a complete list of conflicting code patches to both
> Dave and myself and allow us to pull those patches into both our trees
> so there are no conflicts.  See the recent threads on linux-rdma about
> the pull requests from Mellanox.  This is how it needs to be done.
> Neither team needs to slow down, or not do your work, you simply need
> to
> plan that work out and provide a common base for Dave and I to apply
> the
> separate patches on top of.
I got your point now. Thanks for this clear explanation, Doug. I would
discuss this internally and plan the other non-related HNS conflicting
patches according to the example procedure you indicated in linux-rdma
mail-chain.

> 
> > So, if I understood you correctly, this delta (which could be large),
> when next merge
> > window open would be taken care by you. And we can expect below to be
> part of 4.9
> > 1) RoCE Base driver (*Already Accepted*)
> > 2) ACPI changes for RoCE Driver (*if accepted*)
> >    * ACPI changes for the RoCE Driver
> >    * ACPI changes for RoCE reset function part of the HNS driver
> 
> Both of these changes are already applied to my tree.  However, if you
> submit other changes to net-next and it starts generating merge
> conflicts, you and the net team are going to get yelled at.

Ok thanks. I totally understand that, my current efforts of the discussion
are to understand the process correctly and to ensure that conflict do not
happen.

>  If you are
> going to have a shared driver, then you *HAVE* to work as a larger team
> and plan your changes you submit to the linux kernel.
Sure, agreed
 
> 
> --
> Doug Ledford <dledford@redhat.com>
>     GPG Key ID: 0E572FDD
