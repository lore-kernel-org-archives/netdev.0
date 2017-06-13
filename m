From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH V2 net-next 7/8] net: hns3: Add Ethtool support to HNS3
 driver
Date: Tue, 13 Jun 2017 16:55:14 -0700
Message-ID: <20170613165514.757eb40f@xeon-e3>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
        <20170613231035.494020-8-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
        <huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613231035.494020-8-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 14 Jun 2017 00:10:34 +0100
Salil Mehta <salil.mehta@huawei.com> wrote:

> +/* netdev related stats */
> +#define HNS3_NETDEV_STAT(_string, _member)			\
> +	{ _string,						\
> +	  FIELD_SIZEOF(struct rtnl_link_stats64, _member),	\
> +	  offsetof(struct rtnl_link_stats64, _member),		\
> +	}
> +
> +static const struct hns3_stats hns3_netdev_stats[] = {
> +	/* misc. Rx/Tx statistics */
> +	HNS3_NETDEV_STAT("rx_packets", rx_packets),
> +	HNS3_NETDEV_STAT("tx_packets", tx_packets),
> +	HNS3_NETDEV_STAT("rx_bytes", rx_bytes),
> +	HNS3_NETDEV_STAT("tx_bytes", tx_bytes),
> +	HNS3_NETDEV_STAT("rx_errors", rx_errors),
> +	HNS3_NETDEV_STAT("tx_errors", tx_errors),
> +	HNS3_NETDEV_STAT("rx_dropped", rx_dropped),
> +	HNS3_NETDEV_STAT("tx_dropped", tx_dropped),
> +	HNS3_NETDEV_STAT("multicast", multicast),
> +	HNS3_NETDEV_STAT("collisions", collisions),
> +
> +	/* detailed Rx errors */
> +	HNS3_NETDEV_STAT("rx_length_errors", rx_length_errors),
> +	HNS3_NETDEV_STAT("rx_over_errors", rx_over_errors),
> +	HNS3_NETDEV_STAT("rx_crc_errors", rx_crc_errors),
> +	HNS3_NETDEV_STAT("rx_frame_errors", rx_frame_errors),
> +	HNS3_NETDEV_STAT("rx_fifo_errors", rx_fifo_errors),
> +	HNS3_NETDEV_STAT("rx_missed_errors", rx_missed_errors),
> +
> +	/* detailed Tx errors */
> +	HNS3_NETDEV_STAT("tx_aborted_errors", tx_aborted_errors),
> +	HNS3_NETDEV_STAT("tx_carrier_errors", tx_carrier_errors),
> +	HNS3_NETDEV_STAT("tx_fifo_errors", tx_fifo_errors),
> +	HNS3_NETDEV_STAT("tx_heartbeat_errors", tx_heartbeat_errors),
> +	HNS3_NETDEV_STAT("tx_window_errors", tx_window_errors),
> +

Ethtool statistics should be reserved for device specific values and
should not be used just to clone statistics that already exist in
the network device.
