From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH V5 net-next 6/8] net: hns3: Add MDIO support to HNS3
 Ethernet driver for hip08 SoC
Date: Sat, 29 Jul 2017 01:28:59 +0200
Message-ID: <20170728232859.GB16080@lunn.ch>
References: <20170728222652.118448-1-salil.mehta@huawei.com>
 <20170728222652.118448-7-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
        huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
        mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170728222652.118448-7-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> +int hclge_mac_mdio_config(struct hclge_dev *hdev)
> +{
..

> +}
> +
> +int hclge_mac_start_phy(struct hclge_dev *hdev)
> +{

> +}
> +
> +void hclge_mac_stop_phy(struct hclge_dev *hdev)
> +{
> +}
> -- 

These are not static functions. So i would expect them to be in a
header file somewhere....

       Andrew
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
