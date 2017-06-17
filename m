From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V2 net-next 7/8] net: hns3: Add Ethtool support to HNS3
 driver
Date: Sat, 17 Jun 2017 11:20:28 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B7B2C71@FRAEML521-MBS.china.huawei.com>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
 <20170613231035.494020-8-salil.mehta@huawei.com>
 <20170614021950.GH23384@lunn.ch>
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
        Linuxarm <linuxarm@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170614021950.GH23384@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Wednesday, June 14, 2017 3:20 AM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V2 net-next 7/8] net: hns3: Add Ethtool support to
> HNS3 driver
> 
> > +	switch (media_type) {
> > +	case HNAE3_MEDIA_TYPE_FIBER:
> > +		cmd->base.port = PORT_FIBRE;
> > +		supported_caps = HNS3_LM_FIBRE_BIT | HNS3_LM_AUTONEG_BIT |
> > +			HNS3_LM_PAUSE_BIT | HNS3_LM_40000BASELR4_FULL_BIT |
> > +			HNS3_LM_10000BASEKR_FULL_BIT |
> > +			HNS3_LM_1000BASET_FULL_BIT;
> > +		/* TODO: add speed 100G/50G/25G when ethtool and linux
> kernel
> > +		 * is ready to support.
> 
> Linux already has:
> 
> linux/ethtool.h:	ETHTOOL_LINK_MODE_25000baseCR_Full_BIT	= 31,
> linux/ethtool.h:	ETHTOOL_LINK_MODE_25000baseKR_Full_BIT	= 32,
> linux/ethtool.h:	ETHTOOL_LINK_MODE_25000baseSR_Full_BIT	= 33,
> linux/ethtool.h:	ETHTOOL_LINK_MODE_50000baseCR2_Full_BIT	= 34,
> linux/ethtool.h:	ETHTOOL_LINK_MODE_50000baseKR2_Full_BIT	= 35,
> linux/ethtool.h:	ETHTOOL_LINK_MODE_100000baseKR4_Full_BIT  = 36,
> linux/ethtool.h:	ETHTOOL_LINK_MODE_100000baseSR4_Full_BIT  = 37,
> linux/ethtool.h:	ETHTOOL_LINK_MODE_100000baseCR4_Full_BIT  = 38,
> linux/ethtool.h:	ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT	= 39,
> 
> 	Andrew
Sure thanks. Will consider using them.

Salil
