From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH V4 net-next 7/8] net: hns3: Add Ethtool support to HNS3
 driver
Date: Sun, 23 Jul 2017 10:26:01 -0700
Message-ID: <20170723102601.18ac81a1@xeon-e3>
References: <20170722220942.78852-1-salil.mehta@huawei.com>
        <20170722220942.78852-8-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
        <huangdaode@hisilicon.com>, <lipeng321@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <linuxarm@huawei.com>
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170722220942.78852-8-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 22 Jul 2017 23:09:41 +0100
Salil Mehta <salil.mehta@huawei.com> wrote:

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

Do not put network statistics in ethtool statistics.
This is redundant and unnecessary. Yes some other drivers may do it
but it is not best practice.
