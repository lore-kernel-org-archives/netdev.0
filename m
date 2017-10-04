From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net] RDS: IB: Limit the scope of has_fr/has_fmr
 variables
Date: Tue, 03 Oct 2017 21:06:02 -0700 (PDT)
Message-ID: <20171003.210602.478767133793484738.davem@davemloft.net>
References: <20171001.225655.1261950191787562705.davem@davemloft.net>
        <1172819f-1c28-7756-4874-aa89f50c0733@oracle.com>
        <d1f841a7-0c1d-9d20-ee33-6e260b5d84c4@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: avinash.repaka-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <d1f841a7-0c1d-9d20-ee33-6e260b5d84c4-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date: Tue, 3 Oct 2017 17:42:39 -0700

> Hi Dave,
> 
> On 10/2/2017 1:30 PM, Santosh Shilimkar wrote:
>> On 10/1/2017 10:56 PM, David Miller wrote:
>>> From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> [...]
> 
>>>
>>> Actually, reverted, this breaks the build.
>>>
>>> net/rds/rdma_transport.c:38:10: fatal error: ib.h: No such file or
>>> directory
>>>   #include "ib.h"
>>>
>>> Although I can't see how in the world this patch is causing such
>>> an error.
>>>
>> Weird indeed. Will sort this out with Avinash. Thanks Dave.
>> 
> I tried few build combinations on net-next but couldn't
> reproduce the build failure. AFAIU, the build error can only
> happen if for some reason the ib.h file got deleted
> accidentally. I did delete ib.h file and saw below error
> 
>   CC [M]  net/rds/rdma_transport.o
> net/rds/rdma_transport.c:38:16: error: ib.h: No such file or directory
> 
> Could it be the case for some reason the ib.h file got
> deleted or mangled while applying the $subject patch ?

Please post the patch again, I will try to sort it out.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
