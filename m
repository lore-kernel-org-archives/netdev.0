From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net/mlx5: Simplify a test
Date: Tue, 01 Nov 2016 14:12:49 -0400 (EDT)
Message-ID: <20161101.141249.1579276311119537608.davem@davemloft.net>
References: <20161101071053.12486-1-christophe.jaillet@wanadoo.fr>
        <025cb4e1-f5e8-8bc9-0d4f-3ee8f8d1bb5d@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christophe.jaillet-39ZsbGIQGT5GWvitb5QawA@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <025cb4e1-f5e8-8bc9-0d4f-3ee8f8d1bb5d-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Date: Tue, 1 Nov 2016 11:38:18 +0200

> On 01/11/2016 09:10, Christophe JAILLET wrote:
>> 'create_root_ns()' does not return an error pointer, so the test can
>> be
>> simplified to be more consistent.
>>
>> Signed-off-by: Christophe JAILLET <christophe.jaillet-39ZsbGIQGT5GWvitb5QawA@public.gmane.org>
>> ---
>>  drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
>> b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
>> index 904853f9cf7a..330955f6badc 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
>> @@ -1833,7 +1833,7 @@ static int init_root_ns(struct
>> mlx5_flow_steering *steering)
>>  {
>>
>>  	steering->root_ns = create_root_ns(steering, FS_FT_NIC_RX);
>> -	if (IS_ERR_OR_NULL(steering->root_ns))
>> +	if (!steering->root_ns)
>>  		goto cleanup;
>>
>>  	if (init_root_tree(steering, &root_fs, &steering->root_ns->ns.node))
>>
> 
> Thanks.
> Acked-by: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> 

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
