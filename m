From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V1 04/12] net/mlx5e: Support DCBNL IEEE ETS
Date: Sun, 21 Feb 2016 14:16:04 +0200
Message-ID: <CALzJLG93PRVfjvJpEf8eFKH09uRYxCmvNrazAL+6NyLGsB3Cxw@mail.gmail.com>
References: <1455791573-5270-1-git-send-email-saeedm@mellanox.com>
	<1455791573-5270-5-git-send-email-saeedm@mellanox.com>
	<CAJ3xEMh-6WS4VADHbKgLDduz6rpECate7giXqSNpQP3Se-ZpQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f170.google.com ([209.85.161.170]:33913 "EHLO
	mail-yw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933AbcBURZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 12:25:56 -0500
Received: by mail-yw0-f170.google.com with SMTP id h129so102907307ywb.1
        for <netdev@vger.kernel.org>; Sun, 21 Feb 2016 09:25:56 -0800 (PST)
In-Reply-To: <CAJ3xEMh-6WS4VADHbKgLDduz6rpECate7giXqSNpQP3Se-ZpQw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 18, 2016 at 7:02 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Thu, Feb 18, 2016 at 12:32 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
>
>> @@ -2164,6 +2233,9 @@ static void mlx5e_build_netdev(struct net_device *netdev)
>>         netdev->watchdog_timeo    = 15 * HZ;
>>
>>         netdev->ethtool_ops       = &mlx5e_ethtool_ops;
>> +#ifdef CONFIG_MLX5_CORE_EN_DCB
>> +       netdev->dcbnl_ops         = &mlx5e_dcbnl_ops;
>> +#endif
>
> I guess we don't want VF drivers to control the uplink port QoS
> arbiter, PFC setup and such, agree -- I gave this comment on V0
> and you somehow missed addressing that, please do for V2.

Agree, sorry I missed your comment on V0, will fix it in V3 along with
John's comment.
