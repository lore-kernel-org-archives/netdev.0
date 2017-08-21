From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V4 net-next] net: hns3: Add support to change MTU in
 HNS3 hardware
Date: Mon, 21 Aug 2017 14:58:46 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B875735@FRAEML521-MBX.china.huawei.com>
References: <20170821144003.49436-1-salil.mehta@huawei.com>
 <20170821144838.GO1724@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170821144838.GO1724@mtr-leonro.local>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Leon,

> -----Original Message-----
> From: Leon Romanovsky [mailto:leon@kernel.org]
> Sent: Monday, August 21, 2017 3:49 PM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; linux-rdma@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V4 net-next] net: hns3: Add support to change MTU
> in HNS3 hardware
> 
> On Mon, Aug 21, 2017 at 03:40:03PM +0100, Salil Mehta wrote:
> > This patch adds the following support to the HNS3 driver:
> > 1. Support to change the Maximum Transmission Unit of a
> >    port in the HNS NIC hardware.
> > 2. Initializes the supported MTU range for the netdevice.
> >
> > Signed-off-by: lipeng <lipeng321@huawei.com>
> > Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> > ---
> > PATCH V4: Addressed some minor comments Leon Romanovsky
> >           1. https://lkml.org/lkml/2017/8/21/212
> > PATCH V3: Addressed some minor comments Leon Romanovsky
> >           1. https://lkml.org/lkml/2017/8/20/27
> > PATCH V2: Addresses comments given by Andrew Lunn
> >           1. https://lkml.org/lkml/2017/8/18/282
> > PATCH V1: Initial Submit
> > ---
> >  .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 34
> ++++++++++++++++++++++
> >  .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h |  1 +
> >  2 files changed, 35 insertions(+)
> >
> 
> Wrong error code is not "minor" comment.
Sorry for the wrong terminology used. Both of the comments
were definitely useful and I have taken into consideration
both of them in my recent patch. I think I missed it while
replying, saw it while and created the patch later.
Sorry for that again.

I will correct this in my subsequent patch.

Best regards
Salil
> 
> Thanks,
> Reviewed-by: Leon Romanovsky <leonro@mellanox.com>
