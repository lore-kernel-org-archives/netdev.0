From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [net-next 10/15] net/mlx5: Add a blank line after declarations
Date: Thu, 24 Aug 2017 15:58:57 +0300
Message-ID: <CALzJLG9GOgzOOOM+shw4ECxp6XcteePyBmo6V47_sF=YDYEidA@mail.gmail.com>
References: <20170817133003.16900-1-saeedm@mellanox.com> <20170817133003.16900-11-saeedm@mellanox.com>
 <1503527941.27867.2.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:37697 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751300AbdHXM7T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 08:59:19 -0400
Received: by mail-lf0-f67.google.com with SMTP id s12so1548270lfk.4
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 05:59:19 -0700 (PDT)
In-Reply-To: <1503527941.27867.2.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 24, 2017 at 1:39 AM, Joe Perches <joe@perches.com> wrote:
> On Thu, 2017-08-17 at 16:29 +0300, Saeed Mahameed wrote:
>> From: Or Gerlitz <ogerlitz@mellanox.com>
> []
>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
> []
>> @@ -188,6 +188,7 @@ static enum mlx5_dev_event port_subtype_event(u8 subtype)
>>  static void eq_update_ci(struct mlx5_eq *eq, int arm)
>>  {
>>       __be32 __iomem *addr = eq->doorbell + (arm ? 0 : 2);
>> +
>>       u32 val = (eq->cons_index & 0xffffff) | (eq->eqn << 24);
>>       __raw_writel((__force u32)cpu_to_be32(val), addr);
>>       /* We still want ordering, just not swabbing, so add a barrier */
>
> checkpatch is stupid.
>
> The blank line should be after u32 val = ...
> and not after __be32 __iomem *addr = ...
>
>

You are completely right ! will fix this, Thanks !
