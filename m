From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] ethtool: add one ethtool option to set relax ordering mode
Date: Wed, 4 Jan 2017 08:50:14 -0800
Message-ID: <CAKgT0Uc1AagMt_S9j-CKFwA3ZCMcJ5wd_yTrQrVg8oA3+ythGg@mail.gmail.com>
References: <1481179898-10668-1-git-send-email-maowenan@huawei.com>
 <1481179898-10668-2-git-send-email-maowenan@huawei.com> <20161221172759.1bc0d0dd@xeon-e3>
 <F95AC9340317A84688A5F0DF0246F3F20151F189@szxeml504-mbs.china.huawei.com>
 <CAKgT0Uc2ztu_iDn79zdNtsAdb-Ftu65V6YHV-sqXb6vTCTiGCQ@mail.gmail.com>
 <F95AC9340317A84688A5F0DF0246F3F20151FD1C@szxeml504-mbs.china.huawei.com>
 <1482455203.2481.31.camel@intel.com> <F95AC9340317A84688A5F0DF0246F3F20151FE86@szxeml504-mbs.china.huawei.com>
 <CAKgT0Ud0=fQpADLHPnZBLrG8xLGHUB20TZt1mi+GBNYJQngDCA@mail.gmail.com> <F95AC9340317A84688A5F0DF0246F3F2015240E0@szxeml504-mbs.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>,
        Dingtianhong <dingtianhong@huawei.com>,
        "Wangzhou (B)" <wangzhou1@hisilicon.com>
To: maowenan <maowenan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:32928 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932381AbdADQuP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 11:50:15 -0500
Received: by mail-io0-f169.google.com with SMTP id d9so458219303ioe.0
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 08:50:15 -0800 (PST)
In-Reply-To: <F95AC9340317A84688A5F0DF0246F3F2015240E0@szxeml504-mbs.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 4, 2017 at 1:02 AM, maowenan <maowenan@huawei.com> wrote:
>
>
>> -----Original Message-----
>> From: maowenan
>> Sent: Monday, December 26, 2016 4:33 PM
>> To: maowenan; 'Alexander Duyck'
>> Cc: 'Jeff Kirsher'; 'Stephen Hemminger'; 'netdev@vger.kernel.org'; weiyongjun
>> (A); Dingtianhong; Wangzhou (B)
>> Subject: RE: [PATCH] ethtool: add one ethtool option to set relax ordering mode
>>
>>
>>
>> > -----Original Message-----
>> > From: maowenan
>> > Sent: Saturday, December 24, 2016 4:30 PM
>> > To: 'Alexander Duyck'
>> > Cc: Jeff Kirsher; Stephen Hemminger; netdev@vger.kernel.org;
>> > weiyongjun (A); Dingtianhong; Wangzhou (B)
>> > Subject: RE: [PATCH] ethtool: add one ethtool option to set relax
>> > ordering mode
>> >
>> >
>> >
>> > > -----Original Message-----
>> > > From: Alexander Duyck [mailto:alexander.duyck@gmail.com]
>> > > Sent: Friday, December 23, 2016 11:43 PM
>> > > To: maowenan
>> > > Cc: Jeff Kirsher; Stephen Hemminger; netdev@vger.kernel.org;
>> > > weiyongjun (A); Dingtianhong
>> > > Subject: Re: [PATCH] ethtool: add one ethtool option to set relax
>> > > ordering mode
>> > >
>> > > On Thu, Dec 22, 2016 at 10:14 PM, maowenan <maowenan@huawei.com>
>> > > wrote:
>> > > >
>> > > >
>> > > >> -----Original Message-----
>> > > >> From: Jeff Kirsher [mailto:jeffrey.t.kirsher@intel.com]
>> > > >> Sent: Friday, December 23, 2016 9:07 AM
>> > > >> To: maowenan; Alexander Duyck
>> > > >> Cc: Stephen Hemminger; netdev@vger.kernel.org; weiyongjun (A);
>> > > >> Dingtianhong
>> > > >> Subject: Re: [PATCH] ethtool: add one ethtool option to set relax
>> > > >> ordering mode
>> > > >>
>> > > >> On Fri, 2016-12-23 at 00:40 +0000, maowenan wrote:
>> > > >> > > -----Original Message-----
>> > > >> > > From: Alexander Duyck [mailto:alexander.duyck@gmail.com]
>> > > >> > > Sent: Thursday, December 22, 2016 11:54 PM
>> > > >> > > To: maowenan
>> > > >> > > Cc: Stephen Hemminger; netdev@vger.kernel.org;
>> > > jeffrey.t.kirsher@intel.
>> > > >> > > com;
>> > > >> > > weiyongjun (A); Dingtianhong
>> > > >> > > Subject: Re: [PATCH] ethtool: add one ethtool option to set
>> > > >> > > relax ordering mode
>> > > >> > >
>> > > >> > > On Wed, Dec 21, 2016 at 5:39 PM, maowenan
>> > > <maowenan@huawei.com>
>> > > >> > > wrote:
>> > > >> > > >
>> > > >> > > >
>> > > >> > > > > -----Original Message-----
>> > > >> > > > > From: Stephen Hemminger
>> > > >> > > > > [mailto:stephen@networkplumber.org]
>> > > >> > > > > Sent: Thursday, December 22, 2016 9:28 AM
>> > > >> > > > > To: maowenan
>> > > >> > > > > Cc: netdev@vger.kernel.org; jeffrey.t.kirsher@intel.com
>> > > >> > > > > Subject: Re: [PATCH] ethtool: add one ethtool option to
>> > > >> > > > > set relax ordering mode
>> > > >> > > > >
>> > > >> > > > > On Thu, 8 Dec 2016 14:51:38 +0800 Mao Wenan
>> > > >> > > > > <maowenan@huawei.com> wrote:
>> > > >> > > > >
>> > > >> > > > > > This patch provides one way to set/unset IXGBE NIC TX
>> > > >> > > > > > and RX relax ordering mode, which can be set by ethtool.
>> > > >> > > > > > Relax ordering is one mode of 82599 NIC, to enable this
>> > > >> > > > > > mode can enhance the performance for some cpu architecure.
>> > > >> > > > >
>> > > >> > > > > Then it should be done by CPU architecture specific
>> > > >> > > > > quirks (preferably in PCI
>> > > >> > > > > layer) so that all users get the option without having to
>> > > >> > > > > do manual
>> > > >> > >
>> > > >> > > intervention.
>> > > >> > > > >
>> > > >> > > > > > example:
>> > > >> > > > > > ethtool -s enp1s0f0 relaxorder off ethtool -s enp1s0f0
>> > > >> > > > > > relaxorder on
>> > > >> > > > >
>> > > >> > > > > Doing it via ethtool is a developer API (for testing) not
>> > > >> > > > > something that makes sense in production.
>> > > >> > > >
>> > > >> > > >
>> > > >> > > > This feature is not mandatory for all users, acturally
>> > > >> > > > relax ordering default configuration of 82599 is 'disable',
>> > > >> > > > So this patch gives one way to
>> > > >> > >
>> > > >> > > enable relax ordering to be selected in some performance condition.
>> > > >> > >
>> > > >> > > That isn't quite true.  The default for Sparc systems is to
>> > > >> > > have it enabled.
>> > > >> > >
>> > > >> > > Really this is something that is platform specific.  I agree
>> > > >> > > with Stephen that it would work better if this was handled as
>> > > >> > > a series of platform specific quirks handled at something
>> > > >> > > like the PCI layer rather than be a switch the user can toggle on and
>> off.
>> > > >> > >
>> > > >> > > With that being said there are changes being made that should
>> > > >> > > help to improve the situation.  Specifically I am looking at
>> > > >> > > adding support for the DMA_ATTR_WEAK_ORDERING which may
>> also
>> > > >> > > allow us to identify cases where you might be able to specify
>> > > >> > > the DMA behavior via the DMA mapping instead of having to
>> > > >> > > make the final decision in the device itself.
>> > > >> > >
>> > > >> > > - Alex
>> > > >> >
>> > > >> > Yes, Sparc is a special case. From the NIC driver point of
>> > > >> > view, It is no need for some ARCHs to do particular operation
>> > > >> > and compiling branch, ethtool is a flexible method for user to
>> > > >> > make decision whether
>> > > >> > on|off this feature.
>> > > >> > I think Jeff as maintainer of 82599 has some comments about this.
>> > > >>
>> > > >> My original comment/objection was that you attempted to do this
>> > > >> change as a module parameter to the ixgbe driver, where I
>> > > >> directed you to use ethtool so that other drivers could benefit
>> > > >> from the ability to enable/disable relaxed ordering.  As far as
>> > > >> how it gets implemented in ethtool or PCI layer, makes little
>> > > >> difference to me, I only had issues with the driver specific
>> > > >> module parameter implementation,
>> > > which is not acceptable.
>> > > >
>> > > >
>> > > > Thank you Jeff and Alex.
>> > > > And then I have gone through mail thread about "i40e: enable PCIe
>> > > > relax ordering for SPARC", It only works for SPARC, any other ARCH
>> > > > who wants to enable DMA_ATTR_WEAK_ORDERING feature, should
>> define
>> > > > the
>> > > new macro, recompile the driver module.
>> > > >
>> > > > Because of the above reasons, we implement in ethtool to give the
>> > > > final user a convenient way to on|off special feature, no need
>> > > > define new macro, easy to extend the new features, and also good
>> > > > benefit for other
>> > > driver as Jeff referred.
>> > > >
>> > >
>> > > I think the point is we shouldn't base the decision on user input.
>> > > The fact is the PCIe device control register should have a bit that
>> > > indicates if the device is allowed to enable relaxed ordering or not.
>> > > If we can guarantee that the bit is set in all the cases where it
>> > > should be set, and cleared in all the cases where it should not then
>> > > we could use something like that to determine if the device is
>> > > supposed to enable relaxed ordering instead of trying to make the
>> > > decision
>> > ourselves.
>> > >
>> > > - Alex
>> >
>> > ok. We are focusing on the register.
>> > And yes, to enable relax ordering for 82599 should be set by one or
>> > more bits of Rx/TX DCA Control Register, these bits should be set in
>> > many cpu architectures, such as arm64, sparc, and so on, and should be
>> cleared in other ARCHs.
>> > By the way, how do you enable SPARC macro, how and where to define
>> > this compiling macro when user one to enable relax ordering under SPARC
>> system?
>> > #ifndef CONFIG_SPARC
>> >
>> >
>>
>>
>> Hi, Alex,
>> Have you already sent out the patches about DMA_ATTR_WEAK_ORDERING?
>> We want to get you how to enable DMA_ATTR_WEAK_ORDERING by PCIe layer,
>> and we can refer to that.
>
> I have verified DMA_ATTR_WEAK_ORDERING is not usable for our system(arm64 and 82599),
> We should enable relax ordering in 82599 DCA control register to improve performance.
> As Stephen Hemminger do not suggest use ethtool to set relax ordering feature,
> @Jeff, do you agree with using erratum config to enable RO mode in 82599.
> Codes like below:
> In Kconfig:
> +config HI_ERRATUM_xxxx
>
> In ixgbe_82599.c
> #if !defined (CONFIG_SPARC) || !defined(HI_ERRATUM_xxxx)
>         /* Disable relaxed ordering */
>         for (i = 0; ((i < hw->mac.max_tx_queues) &&
>              (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
>                 regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(i));
>                 regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
>                 IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(i), regval);
>         }
>
>         for (i = 0; ((i < hw->mac.max_rx_queues) &&
>              (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
>                 regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
>                 regval &= ~(IXGBE_DCA_RXCTRL_DATA_WRO_EN |
>                             IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
>                 IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
>         }
> #endif

Instead of having the driver add a flag per architecture maybe it
would be worthwhile to look at adding a config flag that can be set
specifically for the architectures that need it.  Maybe something like
a "ARCH_WANT_RO_DMA" that then drivers could modify their relaxed
ordering flag based on.  Then you could just add the flag to the SPARC
and your arm64 kconfig options and not have to involve the other
architectures.

- Alex
