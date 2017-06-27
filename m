From: Colin Ian King <colin.king@canonical.com>
Subject: Re: [PATCH] net/mlx4: fix spelling mistake: "enforcment" ->
 "enforcement"
Date: Tue, 27 Jun 2017 11:37:19 +0100
Message-ID: <f44a67ff-fee9-68da-6de2-577214ee7110@canonical.com>
References: <20170627100243.15956-1-colin.king@canonical.com>
 <2a0ff12b-69f9-8b20-9c0e-6602f935b838@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2a0ff12b-69f9-8b20-9c0e-6602f935b838@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27/06/17 11:33, Tariq Toukan wrote:
> 
> 
> On 27/06/2017 1:02 PM, Colin King wrote:
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> Trivial fix to spelling mistake in mlx4_dbg debug message
>>
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
>> ---
>>   drivers/net/ethernet/mellanox/mlx4/cmd.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c
>> b/drivers/net/ethernet/mellanox/mlx4/cmd.c
>> index c1af47e45d3f..9e4c142c7ecd 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
>> @@ -3280,7 +3280,7 @@ int mlx4_set_vf_link_state(struct mlx4_dev *dev,
>> int port, int vf, int link_stat
>>         if (mlx4_master_immediate_activate_vlan_qos(priv, slave, port))
>>           mlx4_dbg(dev,
>> -             "updating vf %d port %d no link state HW enforcment\n",
>> +             "updating vf %d port %d no link state HW enforecment\n",
> Hi Colin,
> You still have a typo. It's "enforcement".
>>                vf, port);
>>       return 0;
>>   }
>>
Doh, stupid me. V2 fixes this.
