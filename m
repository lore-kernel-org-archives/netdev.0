From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 4/9] sunvnet: add driver stats for ethtool
 support
Date: Sat, 11 Feb 2017 21:01:01 -0500 (EST)
Message-ID: <20170211.210101.1450332574457722492.davem@davemloft.net>
References: <1486748305-240339-1-git-send-email-shannon.nelson@oracle.com>
        <1486748305-240339-5-git-send-email-shannon.nelson@oracle.com>
        <20170210162208.69485824@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shannon.nelson@oracle.com, netdev@vger.kernel.org,
        sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170210162208.69485824@xeon-e3>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Fri, 10 Feb 2017 16:22:08 -0800

> On Fri, 10 Feb 2017 09:38:20 -0800
> Shannon Nelson <shannon.nelson@oracle.com> wrote:
> 
>> +static void vsw_get_ethtool_stats(struct net_device *dev,
>> +				  struct ethtool_stats *estats, u64 *data)
>> +{
>> +	int i = 0;
>> +
>> +	data[i++] = dev->stats.rx_packets;
>> +	data[i++] = dev->stats.tx_packets;
>> +	data[i++] = dev->stats.rx_bytes;
>> +	data[i++] = dev->stats.tx_bytes;
>> +	data[i++] = dev->stats.rx_errors;
>> +	data[i++] = dev->stats.tx_errors;
>> +	data[i++] = dev->stats.rx_dropped;
>> +	data[i++] = dev->stats.tx_dropped;
>> +	data[i++] = dev->stats.multicast;
> 
> Please do not duplicate regular network statistics into ethtool.
> This doesn't really add any value.

Agreed.
