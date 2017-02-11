From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3 net-next 4/9] sunvnet: add driver stats for ethtool
 support
Date: Fri, 10 Feb 2017 16:22:08 -0800
Message-ID: <20170210162208.69485824@xeon-e3>
References: <1486748305-240339-1-git-send-email-shannon.nelson@oracle.com>
        <1486748305-240339-5-git-send-email-shannon.nelson@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shannon Nelson <shannon.nelson@oracle.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <1486748305-240339-5-git-send-email-shannon.nelson@oracle.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Feb 2017 09:38:20 -0800
Shannon Nelson <shannon.nelson@oracle.com> wrote:

> +static void vsw_get_ethtool_stats(struct net_device *dev,
> +				  struct ethtool_stats *estats, u64 *data)
> +{
> +	int i = 0;
> +
> +	data[i++] = dev->stats.rx_packets;
> +	data[i++] = dev->stats.tx_packets;
> +	data[i++] = dev->stats.rx_bytes;
> +	data[i++] = dev->stats.tx_bytes;
> +	data[i++] = dev->stats.rx_errors;
> +	data[i++] = dev->stats.tx_errors;
> +	data[i++] = dev->stats.rx_dropped;
> +	data[i++] = dev->stats.tx_dropped;
> +	data[i++] = dev->stats.multicast;

Please do not duplicate regular network statistics into ethtool.
This doesn't really add any value.
