From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V1 04/12] net/mlx5e: Support DCBNL IEEE ETS
Date: Thu, 18 Feb 2016 17:58:12 +0200
Message-ID: <CALzJLG-A5nrtUcCVXrxfUxggtbZ34x==NySXWbWzOtdGsS19cA@mail.gmail.com>
References: <1455791573-5270-1-git-send-email-saeedm@mellanox.com>
	<1455791573-5270-5-git-send-email-saeedm@mellanox.com>
	<56C5E37B.20207@gmail.com>
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
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f194.google.com ([209.85.160.194]:34510 "EHLO
	mail-yk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425202AbcBRP6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 10:58:13 -0500
Received: by mail-yk0-f194.google.com with SMTP id z7so1011753yka.1
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 07:58:13 -0800 (PST)
In-Reply-To: <56C5E37B.20207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 18, 2016 at 5:30 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
>
> Hi Saeed,
>
> I just changed the signature on the setup_tc ndo hook so you will
> need to change this to something like,
>
> static int __mlx5e_setup_tc(struct net_device *dev, u32 handle,
>                             __be16 proto, struct tc_to_netdev *tc)
> {
>         if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
>                 return -EINVAL;
>         return mlx5e_setup_tc(dev, tc->tc)
> }
>
>
> and then use __mlx5e_setup_tc() to populate the ndo op hook. If you
> look at the mlx4 drivers I did this change there already.
>
> Other than that nice to see another dcb supporting driver.
>
> Thanks,
> John
Hi John,

Thanks for pointing that out, will fix this out.

Thanks,
Saeed
