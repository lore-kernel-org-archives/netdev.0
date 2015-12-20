From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V1 4/4] net/mlx5e: Add PTP Hardware Clock (PHC) support
Date: Sun, 20 Dec 2015 15:02:54 +0200
Message-ID: <CALzJLG9s9ZxJUf3Jj5RpqX5CS_=_2nNu5dAsXXNMEB1Ncv83eA@mail.gmail.com>
References: <1450355735-30846-1-git-send-email-saeedm@mellanox.com>
	<1450355735-30846-5-git-send-email-saeedm@mellanox.com>
	<20151217202050.GC5975@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:35012 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754319AbbLTNCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Dec 2015 08:02:55 -0500
Received: by mail-yk0-f175.google.com with SMTP id v6so106739824ykc.2
        for <netdev@vger.kernel.org>; Sun, 20 Dec 2015 05:02:54 -0800 (PST)
In-Reply-To: <20151217202050.GC5975@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2015 at 10:20 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Thu, Dec 17, 2015 at 02:35:35PM +0200, Saeed Mahameed wrote:
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
>> index 8e86f2c..b2e5014 100644
>> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
>> @@ -880,6 +880,9 @@ static int mlx5e_get_ts_info(struct net_device *dev,
>>                               (1 << HWTSTAMP_FILTER_ALL);
>>       }
>>
>> +     if (priv->tstamp.ptp)
>> +             info->phc_index = ptp_clock_index(priv->tstamp.ptp);

>         else
>                 info->phc_index = -1;
Will fix this.
Thnks

>
> Thanks,
> Richard
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
