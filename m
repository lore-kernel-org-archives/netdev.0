From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 11/15] net/mlx5e: Properly indent within conditional
 statements
Date: Thu, 17 Aug 2017 10:21:08 -0700 (PDT)
Message-ID: <20170817.102108.1936054141019427795.davem@davemloft.net>
References: <20170817133003.16900-1-saeedm@mellanox.com>
        <20170817133003.16900-12-saeedm@mellanox.com>
        <063D6719AE5E284EB5DD2968C1650D6DD0059721@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, netdev@vger.kernel.org, leonro@mellanox.com,
        ogerlitz@mellanox.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60100 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753360AbdHQRVJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 13:21:09 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0059721@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Thu, 17 Aug 2017 14:18:29 +0000

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
>>  		return ptys2connector_type[connector_type];
>> 
>>  	if (eth_proto & (MLX5E_PROT_MASK(MLX5E_10GBASE_SR)
>> -			 | MLX5E_PROT_MASK(MLX5E_40GBASE_SR4)
>> -			 | MLX5E_PROT_MASK(MLX5E_100GBASE_SR4)
>> -			 | MLX5E_PROT_MASK(MLX5E_1000BASE_CX_SGMII))) {
>> -			return PORT_FIBRE;
>> +	    | MLX5E_PROT_MASK(MLX5E_40GBASE_SR4)
>> +	    | MLX5E_PROT_MASK(MLX5E_100GBASE_SR4)
>> +	    | MLX5E_PROT_MASK(MLX5E_1000BASE_CX_SGMII))) {
>> +		return PORT_FIBRE;
> 
> Gah, that is why the rules are stupid.
> If anything the continuation lines want indenting a few more bytes.

And in fact, operators should be at the end rather the beginning of lines.
This statement therefore must be formatted like this:

	if (x & (A |
		 B |
		 C |
		 C))

The indentation shows the grouping, therefore each line after the first must
start exactly at the column after the inner openning parenthesis.

Please fix this properly.
