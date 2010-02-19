From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: replace the dma_sync_single_range_for_cpu/device
 API
Date: Fri, 19 Feb 2010 12:39:31 -0800 (PST)
Message-ID: <20100219.123931.229106308.davem@davemloft.net>
References: <20100204.210939.133998827.davem@davemloft.net>
	<adavde35rr9.fsf@roland-alpha.cisco.com>
	<20100219164408H.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rolandd@cisco.com, eli@mellanox.co.il,
	linux-kernel@vger.kernel.org
To: fujita.tomonori@lab.ntt.co.jp
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100219164408H.fujita.tomonori@lab.ntt.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Fri, 19 Feb 2010 16:44:29 +0900

> On Thu, 11 Feb 2010 14:31:22 -0800
> Roland Dreier <rdreier@cisco.com> wrote:
> 
>>  > > There are only two users of the dma_sync_single_range_for_cpu/device
>>  > > API in mainline (mlx4 and ssb). The
>>  > > dma_sync_single_range_for_cpu/device API has never been documented and
>>  > > the dma_sync_single_for_cpu/device API also support a partial sync.
>>  > > 
>>  > > This converts mlx4 to use the dma_sync_single_for_cpu/device API
>>  > > (preparations for the removal of the dma_sync_single_range_for_cpu/device API).
>>  > > 
>>  > > Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
>>  > 
>>  > Acked-by: David S. Miller <davem@davemloft.net>
>> 
>> Dave, please go ahead and merge this -- this affects the mlx4 ethernet
>> driver, so it's your area anyway.
> 
> Seems that net-next still doesn't have this. Can you please merge
> this?

I'll take care of this later today.
