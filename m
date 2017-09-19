From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH net 0/7] Bug fixes for the HNS3 Ethernet Driver for
 Hip08 SoC
Date: Tue, 19 Sep 2017 14:12:49 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B8C89E9@FRAEML521-MBX.china.huawei.com>
References: <20170919010628.175732-1-salil.mehta@huawei.com>
 <20170919035900.GI5788@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "lipeng (Y)" <lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linuxarm <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170919035900.GI5788-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Leon,

> -----Original Message-----
> From: Leon Romanovsky [mailto:leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org]
> Sent: Tuesday, September 19, 2017 4:59 AM
> To: Salil Mehta
> Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; Zhuangyuzeng (Yisen); lipeng (Y);
> mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
> kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Linuxarm
> Subject: Re: [PATCH net 0/7] Bug fixes for the HNS3 Ethernet Driver for
> Hip08 SoC
> 
> On Tue, Sep 19, 2017 at 02:06:21AM +0100, Salil Mehta wrote:
> > This patch set presents some bug fixes for the HNS3 Ethernet driver,
> identified
> > during internal testing & stabilization efforts.
> >
> > This patch series is meant for Linux 4.14 kernel.
> >
> > Lipeng (6):
> >   net: hns3: get phy addr from NCL_config
> >   net: hns3: fix the command used to unmap ring from vector
> >   net: hns3: Fix ring and vector map command
> >   net: hns3: fix a bug of set mac address
> >   net: hns3: set default vlan id to PF
> >   net: hns3: Fixes the premature exit of loop when matching clients
> >
> > Salil Mehta (1):
> >   net: hns3: fixes the ether address copy with more appropriate API
> 
> 1. The fixes patches should have Fixes line and not all of them have
> (I didn't look all patches).
> 2. Please decide on one style: fixes vs. Fixes, fix vs. Fix in the
> titles
> 3. Subject should be descriptive and usable, I don't know if it applies
> to the "fix a bug of set mac address" patch.
Yes, missed these. Will fix them. Thanks!

Salil
> 
> Thanks
> 
> >
> >  drivers/net/ethernet/hisilicon/hns3/hnae3.c        | 43 +++++-------
> ----------
> >  .../net/ethernet/hisilicon/hns3/hns3pf/hclge_cmd.h |  8 +++-
> >  .../ethernet/hisilicon/hns3/hns3pf/hclge_main.c    | 20 ++++++++--
> >  .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c |  7 ++--
> >  4 files changed, 35 insertions(+), 43 deletions(-)
> >
> > --
> > 2.11.0
> >
> >
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
