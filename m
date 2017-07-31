From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V5 net-next 7/8] net: hns3: Add Ethtool support to HNS3
 driver
Date: Mon, 31 Jul 2017 15:05:36 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B82D975@FRAEML521-MBX.china.huawei.com>
References: <20170728222652.118448-1-salil.mehta@huawei.com>
 <20170728222652.118448-8-salil.mehta@huawei.com>
 <20170728234922.GC16080@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lhrrgout.huawei.com ([194.213.3.17]:32447 "EHLO
        lhrrgout.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752391AbdGaPFv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 11:05:51 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

> -----Original Message-----
> From: Salil Mehta
> Sent: Saturday, July 29, 2017 12:57 AM
> To: 'Andrew Lunn'
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; linux-rdma@vger.kernel.org; Linuxarm
> Subject: RE: [PATCH V5 net-next 7/8] net: hns3: Add Ethtool support to
> HNS3 driver
> 
> Hi Andrew,
> 
> > -----Original Message-----
> > From: Andrew Lunn [mailto:andrew@lunn.ch]
> > Sent: Saturday, July 29, 2017 12:49 AM
> > To: Salil Mehta
> > Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng
> (Y);
> > mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> > kernel@vger.kernel.org; linux-rdma@vger.kernel.org; Linuxarm
> > Subject: Re: [PATCH V5 net-next 7/8] net: hns3: Add Ethtool support
> to
> > HNS3 driver
> >
> > On Fri, Jul 28, 2017 at 11:26:51PM +0100, Salil Mehta wrote:
> > > +static const struct hns3_link_mode_mapping hns3_lm_map[] = {
> > > +	{HNS3_LM_FIBRE_BIT, ETHTOOL_LINK_MODE_FIBRE_BIT, FLG},
> > > +	{HNS3_LM_AUTONEG_BIT, ETHTOOL_LINK_MODE_Autoneg_BIT, FLG},
> > > +	{HNS3_LM_TP_BIT, ETHTOOL_LINK_MODE_TP_BIT, FLG},
> > > +	{HNS3_LM_PAUSE_BIT, ETHTOOL_LINK_MODE_Pause_BIT, FLG},
> > > +	{HNS3_LM_BACKPLANE_BIT, ETHTOOL_LINK_MODE_Backplane_BIT, FLG},
> > > +	{HNS3_LM_10BASET_HALF_BIT, ETHTOOL_LINK_MODE_10baseT_Half_BIT,
> > FLG},
> > > +	{HNS3_LM_10BASET_FULL_BIT, ETHTOOL_LINK_MODE_10baseT_Full_BIT,
> > FLG},
> > > +	{HNS3_LM_100BASET_HALF_BIT, ETHTOOL_LINK_MODE_100baseT_Half_BIT,
> > FLG},
> > > +	{HNS3_LM_100BASET_FULL_BIT, ETHTOOL_LINK_MODE_100baseT_Full_BIT,
> > FLG},
> > > +	{HNS3_LM_1000BASET_FULL_BIT,
> > ETHTOOL_LINK_MODE_1000baseT_Full_BIT, FLG},
> > > +};
> >
> > It seems like all entries have link_mode_ksettings set to FLG. Which
> > probably indicates it is pointless.
> It is to support SUPPORTED and ADVERTISED link modes.
I can see what you are saying now. Will remove FLG in next patch.

Thanks
Salil
