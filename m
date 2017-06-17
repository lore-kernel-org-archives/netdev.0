From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V2 net-next 7/8] net: hns3: Add Ethtool support to HNS3
 driver
Date: Sat, 17 Jun 2017 11:05:27 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B7B2C11@FRAEML521-MBS.china.huawei.com>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
        <20170613231035.494020-8-salil.mehta@huawei.com>
 <20170613165514.757eb40f@xeon-e3>
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
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613165514.757eb40f@xeon-e3>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Wednesday, June 14, 2017 12:55 AM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V2 net-next 7/8] net: hns3: Add Ethtool support to
> HNS3 driver
> 
> On Wed, 14 Jun 2017 00:10:34 +0100
> Salil Mehta <salil.mehta@huawei.com> wrote:
> 
> > +/* netdev related stats */
> > +#define HNS3_NETDEV_STAT(_string, _member)			\
> > +	{ _string,						\
> > +	  FIELD_SIZEOF(struct rtnl_link_stats64, _member),	\
> > +	  offsetof(struct rtnl_link_stats64, _member),		\
> > +	}
> > +
> > +static const struct hns3_stats hns3_netdev_stats[] = {
> > +	/* misc. Rx/Tx statistics */
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
> > +	HNS3_NETDEV_STAT("rx_length_errors", rx_length_errors),
> > +	HNS3_NETDEV_STAT("rx_over_errors", rx_over_errors),
> > +	HNS3_NETDEV_STAT("rx_crc_errors", rx_crc_errors),
> > +	HNS3_NETDEV_STAT("rx_frame_errors", rx_frame_errors),
> > +	HNS3_NETDEV_STAT("rx_fifo_errors", rx_fifo_errors),
> > +	HNS3_NETDEV_STAT("rx_missed_errors", rx_missed_errors),
> > +
> > +	/* detailed Tx errors */
> > +	HNS3_NETDEV_STAT("tx_aborted_errors", tx_aborted_errors),
> > +	HNS3_NETDEV_STAT("tx_carrier_errors", tx_carrier_errors),
> > +	HNS3_NETDEV_STAT("tx_fifo_errors", tx_fifo_errors),
> > +	HNS3_NETDEV_STAT("tx_heartbeat_errors", tx_heartbeat_errors),
> > +	HNS3_NETDEV_STAT("tx_window_errors", tx_window_errors),
> > +
> 
> Ethtool statistics should be reserved for device specific values and
> should not be used just to clone statistics that already exist in
> the network device.
We saw an example from some of the existing drivers like netronome, apm,
intel etc. in the mainline and so thought this can be done. 
But your point about ethtool to be used only for device specific stats
definitely makes sense to me. 
Do you think We can live with this for now or do you wish to change it?

Many thanks!

Best regards
Salil
