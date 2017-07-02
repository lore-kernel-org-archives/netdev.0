From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH][-next] net/mlx5: fix spelling mistake: "Allodating" -> "Allocating"
Date: Sun, 2 Jul 2017 11:35:44 +0300
Message-ID: <CALzJLG--=BLto0QszB71LdWqUuj-SxGGbbGLSQ=ckiCRUkCQ-g@mail.gmail.com>
References: <20170630105922.10397-1-colin.king@canonical.com> <20170701.144003.1643313481741710568.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: colin.king@canonical.com, Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        linux-rdma@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36494 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751635AbdGBIgG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Jul 2017 04:36:06 -0400
Received: by mail-qk0-f196.google.com with SMTP id v143so7844701qkb.3
        for <netdev@vger.kernel.org>; Sun, 02 Jul 2017 01:36:06 -0700 (PDT)
In-Reply-To: <20170701.144003.1643313481741710568.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 2, 2017 at 12:40 AM, David Miller <davem@davemloft.net> wrote:
> From: Colin King <colin.king@canonical.com>
> Date: Fri, 30 Jun 2017 11:59:22 +0100
>
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> Trivial fix to spelling mistake in mlx5_core_dbg debug message
>>
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
>
> Applied, thanks Colin.
>
> Mellanox folks, I don't like how these lib/ objects are built.
>
> I absolutely depend upon being able to try and build individual
> object files, by name, in order to quickly smoke-test patches.
> Like this:
>
> [davem@kkuri net-next]$ make drivers/net/ethernet/mellanox/mlx5/core/lib/gid.o
>
> But I can't for these files:
>
> scripts/Makefile.build:44: drivers/net/ethernet/mellanox/mlx5/core/lib/Makefile: No such file or directory
> make[1]: *** No rule to make target 'drivers/net/ethernet/mellanox/mlx5/core/lib/Makefile'.  Stop.
> Makefile:1663: recipe for target 'drivers/net/ethernet/mellanox/mlx5/core/lib/gid.o' failed
>
> Please fix this so that I can build all object files by name in this driver
> again.

Hi Dave,
We are going to provide a fix ASAP.

>
> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
