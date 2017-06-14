From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V2 net-next 7/8] net: hns3: Add Ethtool support to HNS3
 driver
Date: Wed, 14 Jun 2017 04:19:50 +0200
Message-ID: <20170614021950.GH23384@lunn.ch>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
 <20170613231035.494020-8-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, yisen.zhuang@huawei.com,
        huangdaode@hisilicon.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170613231035.494020-8-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +	switch (media_type) {
> +	case HNAE3_MEDIA_TYPE_FIBER:
> +		cmd->base.port = PORT_FIBRE;
> +		supported_caps = HNS3_LM_FIBRE_BIT | HNS3_LM_AUTONEG_BIT |
> +			HNS3_LM_PAUSE_BIT | HNS3_LM_40000BASELR4_FULL_BIT |
> +			HNS3_LM_10000BASEKR_FULL_BIT |
> +			HNS3_LM_1000BASET_FULL_BIT;
> +		/* TODO: add speed 100G/50G/25G when ethtool and linux kernel
> +		 * is ready to support.

Linux already has:

linux/ethtool.h:	ETHTOOL_LINK_MODE_25000baseCR_Full_BIT	= 31,
linux/ethtool.h:	ETHTOOL_LINK_MODE_25000baseKR_Full_BIT	= 32,
linux/ethtool.h:	ETHTOOL_LINK_MODE_25000baseSR_Full_BIT	= 33,
linux/ethtool.h:	ETHTOOL_LINK_MODE_50000baseCR2_Full_BIT	= 34,
linux/ethtool.h:	ETHTOOL_LINK_MODE_50000baseKR2_Full_BIT	= 35,
linux/ethtool.h:	ETHTOOL_LINK_MODE_100000baseKR4_Full_BIT  = 36,
linux/ethtool.h:	ETHTOOL_LINK_MODE_100000baseSR4_Full_BIT  = 37,
linux/ethtool.h:	ETHTOOL_LINK_MODE_100000baseCR4_Full_BIT  = 38,
linux/ethtool.h:	ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT	= 39,

	Andrew
