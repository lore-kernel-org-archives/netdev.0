From: Ido Shamai <idos@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V2 1/2] net/mlx4: Set number of RX rings in a
 utility function
Date: Fri, 21 Feb 2014 13:41:59 +0200
Message-ID: <53073B87.2050303@dev.mellanox.co.il>
References: <1392979158-18093-1-git-send-email-amirv@mellanox.com> <1392979158-18093-2-git-send-email-amirv@mellanox.com> <063D6719AE5E284EB5DD2968C1650D6D0F6C800B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ido Shamay <idos@mellanox.com>
To: David Laight <David.Laight@ACULAB.COM>,
	'Amir Vadai' <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:64714 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754815AbaBULmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 06:42:04 -0500
Received: by mail-wi0-f178.google.com with SMTP id cc10so715925wib.5
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 03:42:03 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6C800B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/21/2014 1:01 PM, David Laight wrote:
> From: Amir Vadai
>> From: Ido Shamay <idos@mellanox.com>
>>
>> mlx4_en_add() is too long.
>> Moving set number of RX rings to a utiltity function to improve
>> readability and modulization of the code.
> ...
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
>> @@ -318,6 +318,28 @@ static void mlx4_en_free_rx_buf(struct mlx4_en_priv *priv,
>>   	}
>>   }
>>
>> +void mlx4_en_set_num_rx_rings(struct mlx4_en_dev *mdev)
>> +{
>
> Should be static.
It's not in the same c file.
Function was defined in en_rx.c for better modularization.
It may be in use by other files (ethtool.c) in the future
Ido
>
> 	David
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
