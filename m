From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [net-next 11/15] net/mlx5e: Properly indent within conditional statements
Date: Thu, 17 Aug 2017 18:35:10 +0300
Message-ID: <CALzJLG-g7V0mmFYT2+j=DGWNHiuYk44BbfCW77zsORmEr2xWWA@mail.gmail.com>
References: <20170817133003.16900-1-saeedm@mellanox.com> <20170817133003.16900-12-saeedm@mellanox.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0059721@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34169 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751882AbdHQPfb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 11:35:31 -0400
Received: by mail-lf0-f68.google.com with SMTP id o85so4621605lff.1
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 08:35:31 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0059721@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 17, 2017 at 5:18 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Saeed Mahameed
>> Sent: 17 August 2017 14:30
>> To: David S. Miller
>> Cc: netdev@vger.kernel.org; Leon Romanovsky; Or Gerlitz; Saeed Mahameed
>> Subject: [net-next 11/15] net/mlx5e: Properly indent within conditional statements
>>
>> From: Or Gerlitz <ogerlitz@mellanox.com>
>>
>> To fix these checkpatch complaints:
>>
>> WARNING: suspect code indent for conditional statements (8, 24)
>> +       if (eth_proto & (MLX5E_PROT_MASK(MLX5E_10GBASE_SR)
>> [...]
>> +                       return PORT_FIBRE;
>>
>> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
>> ---
>>  .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 22 +++++++++++-----------
>>  1 file changed, 11 insertions(+), 11 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
>> b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
>> index a75ac4d11c5b..ed161312a773 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
>> @@ -988,23 +988,23 @@ static u8 get_connector_port(u32 eth_proto, u8 connector_type)
>>               return ptys2connector_type[connector_type];
>>
>>       if (eth_proto & (MLX5E_PROT_MASK(MLX5E_10GBASE_SR)
>> -                      | MLX5E_PROT_MASK(MLX5E_40GBASE_SR4)
>> -                      | MLX5E_PROT_MASK(MLX5E_100GBASE_SR4)
>> -                      | MLX5E_PROT_MASK(MLX5E_1000BASE_CX_SGMII))) {
>> -                     return PORT_FIBRE;
>> +         | MLX5E_PROT_MASK(MLX5E_40GBASE_SR4)
>> +         | MLX5E_PROT_MASK(MLX5E_100GBASE_SR4)
>> +         | MLX5E_PROT_MASK(MLX5E_1000BASE_CX_SGMII))) {
>> +             return PORT_FIBRE;
>
> Gah, that is why the rules are stupid.
> If anything the continuation lines want indenting a few more bytes.
>

Totally agree,
But if Or wants to follow the rules, I won't stand in his way :).

>         David
>
