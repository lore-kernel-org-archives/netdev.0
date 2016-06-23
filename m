From: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH] mellanox: mlx5: Use logging functions to reduce text ~10k/5%
Date: Thu, 23 Jun 2016 11:12:23 +0300
Message-ID: <CALzJLG-EvhZXZRQNJojUvmR_9KPTsq+pEtsjxhpnTtZ3aho+0w@mail.gmail.com>
References: <1466619839.13093.4.camel@perches.com> <20160623052701.GB30933@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160623052701.GB30933-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 23, 2016 at 8:27 AM, Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
> On Wed, Jun 22, 2016 at 11:23:59AM -0700, Joe Perches wrote:
>> The logging macros create a bit of duplicated code/text.
>>
>> Use specialized functions to reduce the duplication.
>>
>> (defconfig/x86-64)
>> $ size drivers/net/ethernet/mellanox/mlx5/core/built-in.o*
>>    text          data     bss     dec     hex filename
>>  178634          2059      16  180709   2c1e5 drivers/net/ethernet/mellanox/mlx5/core/built-in.o.new
>>  188679          2059      16  190754   2e922 drivers/net/ethernet/mellanox/mlx5/core/built-in.o.old
>>
>> The output changes now do not include line #,
>> but do include the function offset.
>>
>> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
>
> As far as I see all these functions are used in error paths, so no
> implication on performance is expected.
>
> And I'm fine with function offsets.
>
> Saeed,
> What do you think?

Fine with me, need to fix my comment on functions placement, an your
comment on checkpatch.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
