From: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH V4 net-next 7/8] net: hns3: Add Ethtool support to HNS3
 driver
Date: Thu, 27 Jul 2017 15:53:57 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B828136@FRAEML521-MBX.china.huawei.com>
References: <20170722220942.78852-1-salil.mehta@huawei.com>
        <20170722220942.78852-8-salil.mehta@huawei.com>
 <20170723102601.18ac81a1@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        huangdaode <huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
        "lipeng (Y)" <lipeng321-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linuxarm <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170723102601.18ac81a1@xeon-e3>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org]
> Sent: Sunday, July 23, 2017 6:26 PM
> To: Salil Mehta
> Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
> kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Linuxarm
> Subject: Re: [PATCH V4 net-next 7/8] net: hns3: Add Ethtool support to
> HNS3 driver
> 
> On Sat, 22 Jul 2017 23:09:41 +0100
> Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> wrote:
> 
> > +	HNS3_NETDEV_STAT("rx_packets", rx_packets),
> > +	HNS3_NETDEV_STAT("tx_packets", tx_packets),
> > +	HNS3_NETDEV_STAT("rx_bytes", rx_bytes),
> > +	HNS3_NETDEV_STAT("tx_bytes", tx_bytes),
> > +	HNS3_NETDEV_STAT("rx_errors", rx_errors),
> > +	HNS3_NETDEV_STAT("tx_errors", tx_errors),
> > +	HNS3_NETDEV_STAT("rx_dropped", rx_dropped),
> > +	HNS3_NETDEV_STAT("tx_dropped", tx_dropped),
> > +	HNS3_NETDEV_STAT("multicast", multicast),
> > +	HNS3_NETDEV_STAT("collisions", collisions),
> > +
> > +	/* detailed Rx errors */
> 
> Do not put network statistics in ethtool statistics.
> This is redundant and unnecessary. Yes some other drivers may do it
> but it is not best practice.

Ok sure, will remove netdev stats from the ethtool.

Thanks
Salil
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
