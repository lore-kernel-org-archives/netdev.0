From: Weidong Wang <wangweidong1@huawei.com>
Subject: Re: [PATCH net-next v2] BNX2: fix a Null Pointer for stats_blk
Date: Tue, 29 Sep 2015 11:15:24 +0800
Message-ID: <560A024C.2020303@huawei.com>
References: <56014CC0.3050201@huawei.com> <5608E5DE.6010706@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<rui.xiang@huawei.com>, <manish.chopra@qlogic.com>
To: <sony.chacko@qlogic.com>, <Dept-HSGLinuxNICDev@qlogic.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5608E5DE.6010706@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015/9/28 15:01, Weidong Wang wrote:
> we have two processes to do:
> P1#: ifconfig eth0 down; which will call bnx2_close, then will
> , and set Null to stats_blk
> P2#: ifconfig eth0; which will call bnx2_get_stats64, it will
> use stats_blk.
> In one case:
>     --P1#--                   --P2#--
>                               stats_blk(no null)
>     bnx2_free_mem
>     ->bp->stats_blk = NULL
>                               GET_64BIT_NET_STATS
> 
> then it will cause 'NULL Pointer' Problem.
> it is as well with 'ethtool -S ethx'.
> 
> Allocate the statistics block at probe time so that this problem is
> impossible
> 
> Signed-off-by: Tianhong Ding <dingtianhong@huawei.com>
> ---

Sorry for that, The sob is Error. I will fixed it.

Just Ignore it.

Regards.
Weidong
