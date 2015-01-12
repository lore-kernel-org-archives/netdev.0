From: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v11 3/3] net: hisilicon: new hip04 ethernet driver
Date: Mon, 12 Jan 2015 17:04:43 +0800
Message-ID: <54B38E2B.4060105@huawei.com>
References: <1421049832-6224-1-git-send-email-dingtianhong@huawei.com> <1421049832-6224-4-git-send-email-dingtianhong@huawei.com> <19225293.OPozO1Cbk5@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>, <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	<eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <19225293.OPozO1Cbk5@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2015/1/12 16:52, Arnd Bergmann wrote:
> On Monday 12 January 2015 16:03:52 Ding Tianhong wrote:
>> Support Hisilicon hip04 ethernet driver, including 100M / 1000M controller.
>> The controller has no tx done interrupt, reclaim xmitted buffer in the poll.
> 
> Looks great to me in the latest version. Dave, unless you have further
> concerns, please apply.
> 
>> v11: Add ethtool support for tx coalecse getting and setting, the xmit_more
>> is not supported for this patch, but I think it could work for hip04,
>> will support it later after some tests for performance better.
>>
>> Here are some performance test results by ping and iperf(add tx_coalesce_frames/users),
>> it looks that the performance and latency is more better by tx_coalesce_frames/usecs.
>>
>> - Before:
>> $ ping 192.168.1.1 ...
>> --- 192.168.1.1 ping statistics ---
>> 24 packets transmitted, 24 received, 0% packet loss, time 22999ms
>> rtt min/avg/max/mdev = 0.180/0.202/0.403/0.043 ms
>>
>> $ iperf -c 192.168.1.1 ...
>> [ ID] Interval       Transfer     Bandwidth
>> [  3]  0.0- 1.0 sec   115 MBytes   945 Mbits/sec
> 
> Just to be sure: you were running the two tests simultaneously, right?
> 
> 	Arnd
> 
Yes, sure, and try several times, record the more appropriate test results. :)

Ding

> .
> 


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
