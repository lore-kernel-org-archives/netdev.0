From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 00/19] slight optimization of addr compare
 for net modules
Date: Tue, 31 Dec 2013 16:49:12 -0500 (EST)
Message-ID: <20131231.164912.1373331336904065031.davem@davemloft.net>
References: <52C12369.7020206@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	edumazet@google.com
To: dingtianhong@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52C12369.7020206@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Mon, 30 Dec 2013 15:40:25 +0800

> This is the second patchset for slight optimization of address compare,
> mainly for net tree, just following the Joe's opinion, it will help review
> the code for maintainers and supports.
> 
> v2: Change some style for patch 2.
>     According Eric's suggestion, use the ether_addr_equal_64bits to instead
>     of ether_addr_equal for patch 19.
>     In fact, there are a lot of places which could use ether_addr_equal_64bits
>     to instead of ether_addr_equal, but not this time, thanks for Joe's
>     opinion.
> 
> v3: Change some style for patch 11/19:
>     (net: packetengines: slight optimization of addr compare).
>     Joe pointed out that is_broadcast_ether_addr(addr) would be appropriate here,
>     but this should be left alone and not in this patch, so fix it later.
> 
>     In the patch (net: caif: slight optimization of addr compare), the operand for
>     memcmp is not mac address, so it is unsuitable to use the ether_addr_equal
>     to compare a non mac address, so remove the patch from the series.

Series applied, thanks.
