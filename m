From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next v11 3/3] net: hisilicon: new hip04 ethernet driver
Date: Mon, 12 Jan 2015 09:52:57 +0100
Message-ID: <19225293.OPozO1Cbk5@wuerfel>
References: <1421049832-6224-1-git-send-email-dingtianhong@huawei.com> <1421049832-6224-4-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ding Tianhong <dingtianhong@huawei.com>, robh+dt@kernel.org,
	davem@davemloft.net, grant.likely@linaro.org,
	devicetree@vger.kernel.org, linux@arm.linux.org.uk,
	sergei.shtylyov@cogentembedded.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xuwei5@hisilicon.com,
	zhangfei.gao@linaro.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:50486 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbbALIxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 03:53:52 -0500
In-Reply-To: <1421049832-6224-4-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 12 January 2015 16:03:52 Ding Tianhong wrote:
> Support Hisilicon hip04 ethernet driver, including 100M / 1000M controller.
> The controller has no tx done interrupt, reclaim xmitted buffer in the poll.

Looks great to me in the latest version. Dave, unless you have further
concerns, please apply.

> v11: Add ethtool support for tx coalecse getting and setting, the xmit_more
> is not supported for this patch, but I think it could work for hip04,
> will support it later after some tests for performance better.
> 
> Here are some performance test results by ping and iperf(add tx_coalesce_frames/users),
> it looks that the performance and latency is more better by tx_coalesce_frames/usecs.
> 
> - Before:
> $ ping 192.168.1.1 ...
> --- 192.168.1.1 ping statistics ---
> 24 packets transmitted, 24 received, 0% packet loss, time 22999ms
> rtt min/avg/max/mdev = 0.180/0.202/0.403/0.043 ms
> 
> $ iperf -c 192.168.1.1 ...
> [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0- 1.0 sec   115 MBytes   945 Mbits/sec

Just to be sure: you were running the two tests simultaneously, right?

	Arnd
