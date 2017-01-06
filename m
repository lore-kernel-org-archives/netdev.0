From: David Miller <davem-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [for-next 07/10] IB/mlx5: Use blue flame register allocator in
 mlx5_ib
Date: Fri, 06 Jan 2017 11:11:31 -0500 (EST)
Message-ID: <20170106.111131.1775665484264248231.davem@redhat.com>
References: <CAL3tnx4H2HsGMH=caiobivvvs0AU9yrzCmVONOdUQ_j_JMfufA@mail.gmail.com>
        <20170105.150731.2097384465565543422.davem@davemloft.net>
        <20170106060608.GG15685@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170106060608.GG15685-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Date: Fri, 6 Jan 2017 08:06:09 +0200

> On Thu, Jan 05, 2017 at 03:07:31PM -0500, David Miller wrote:
>> From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
>> Date: Thu, 5 Jan 2017 14:03:18 -0600
>>
>> > If necessary I can make sure it builds on 32 bits as well.
>>
>> Please do.
> 
> Dave,
> 
> I'm failing to understand the benefits of building mlx5 on 32 bits, and
> see only disadvantages:
>  * It is actual dead code without test coverage.
>  * It misleads reviewers/customers by seeing code for 32 bits.
>  * It adds compilation time for 32 bits platforms and "punishes" them
>    for not relevant for them driver.
> 
> Why do you call removing all that as a "regression"?

We have this thing called "CONFIG_COMPILE_TEST", it has tons of value,
perhaps you've seen it before?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
