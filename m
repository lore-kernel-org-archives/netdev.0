From: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [patch v2] net/mlx5: missing error code in
 esw_create_offloads_fdb_table()
Date: Wed, 13 Jul 2016 16:17:05 +0300
Message-ID: <83288161-1577-4092-6d6d-125b219cedf9@mellanox.com>
References: <83d5a5bb-dbf5-6c8f-39ea-320d55026a9d@mellanox.com>
 <20160713100825.GD29468@mwanda> <20160713130459.GF10079@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160713130459.GF10079-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 13/07/2016 16:04, Leon Romanovsky wrote:
> On Wed, Jul 13, 2016 at 02:48:44PM +0300, Dan Carpenter wrote:
>> We accidentally return success when we had intended to return an error
>> code.
>>
>> Fixes: 69697b6e2086 ('net/mlx5: E-Switch, Add support for the sriov offloads mode')
>> Signed-off-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
>> ---
>> v2: return -ENOTSUPP instead --EINVAL
>
> I'm a little bit confused. Why did you prefer ENOTSUPP over EOPNOTSUPP?

According to [1], it fits our case better - operation is valid and make 
sense, but isn't supported.

[1] https://lists.gnu.org/archive/html/bug-glibc/2002-08/msg00017.html

>
> Thanks.
>

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
