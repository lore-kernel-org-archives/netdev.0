From: Chen Gang <gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] drivers: net: ethernet: mellanox: mlx4: let mlx4 depend
 on SMP
Date: Sat, 17 May 2014 13:42:25 +0800
Message-ID: <5376F6C1.7000907@gmail.com>
References: <5376F2F8.3010603@gmail.com> <20140517.013655.349586284786993619.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	eyalpe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, sbohrer-EgGFQ3RFNTIP7C3xziwOQw@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140517.013655.349586284786993619.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/17/2014 01:36 PM, David Miller wrote:
> From: Chen Gang <gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Sat, 17 May 2014 13:26:16 +0800
> 
>> 'struct irq_affinity_notify' and the related functions are only defined
>> when SMP enabled, so at present, mlx4 has to only run under SMP.
>>
>> The related error (allmodconfig under unicore32):
> 
> Making the entire driver depend upon SMP is not the answer,
> other Mellanox developers said that a proper fix is pending
> so please be patient.
> 

OK, thank you for your information. I shall bypass it, and continue.

Thanks.
-- 
Chen Gang

Open, share, and attitude like air, water, and life which God blessed
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
