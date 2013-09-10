From: David Miller <davem@davemloft.net>
Subject: Re: [request for stable inclusion] net: neighbour: prohibit
 negative value for unres_qlen_bytes parameter
Date: Tue, 10 Sep 2013 13:55:26 -0400 (EDT)
Message-ID: <20130910.135526.1863493803956191042.davem@davemloft.net>
References: <5201BD94.4060100@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
	davidshan@tencent.com, dingtianhong@huawei.com, lizefan@huawei.com
To: wangweidong1@huawei.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <5201BD94.4060100@huawei.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: wangweidong <wangweidong1@huawei.com>
Date: Wed, 7 Aug 2013 11:23:00 +0800

> Hi Shan Wei or David,
> 
> ce46cc64d47a8afaf13c300b09a7f9c29f4979b6
> net: neighbour: prohibit negative value for unres_qlen_bytes parameter
> 
> This looks applicable to stable-3.4, I can reproduce it on this 3.4 kernel.
> It fixes a type overflow when setting unres_qlen. I try to reproduce, and
> then this patch works well. But git am or patch -p1 failed, because a
> previous patch [commit 9a6308d74ed (neighbour: Stop using NLA_PUT*().)]
> change the NLA_PUT_U32 to nla_put_u32. With some modifies, it was built
> successful for me. What do you think?

Queued up, thanks.
