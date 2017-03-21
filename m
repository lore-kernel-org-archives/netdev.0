From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: mlx5e backports for v4.9 -stable
Date: Tue, 21 Mar 2017 11:42:09 +0200
Message-ID: <CALzJLG8bvsTHXj0_BTOS_6XVhRzocc=1WMNvWCVxCdqPUeh-gA@mail.gmail.com>
References: <20170316.170631.2026655873781156952.davem@davemloft.net> <a53a8f31-a01f-50ee-7aef-4c1a37f2c393@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Tariq Toukan <tariqt@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:35293 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756409AbdCUJmh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 05:42:37 -0400
Received: by mail-qt0-f194.google.com with SMTP id r5so20657647qtb.2
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 02:42:30 -0700 (PDT)
In-Reply-To: <a53a8f31-a01f-50ee-7aef-4c1a37f2c393@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 20, 2017 at 11:32 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
>
>
> On 03/17/2017 02:06 AM, David Miller wrote:
>>
>> Commits:
>>
>> ====================
>> From b0d4660b4cc52e6477ca3a43435351d565dfcedc Mon Sep 17 00:00:00 2001
>> From: Tariq Toukan <tariqt@mellanox.com>
>> Date: Wed, 22 Feb 2017 17:20:14 +0200
>> Subject: [PATCH] net/mlx5e: Fix broken CQE compression initialization
>> ====================
>>
>> and
>>
>> ====================
>> From 6dc4b54e77282caf17f0ff72aa32dd296037fbc0 Mon Sep 17 00:00:00 2001
>> From: Saeed Mahameed <saeedm@mellanox.com>
>> Date: Wed, 22 Feb 2017 17:20:15 +0200
>> Subject: [PATCH] net/mlx5e: Update MPWQE stride size when modifying CQE
>>  compress state
>> ====================
>>
>> do not apply even closely to v4.9 while I was working on -stable backports.
>>
>> Please provide proper backports of these two patches if you want them to
>> show up in v4.9 -stable.
>>
>
> Hi Dave,
>
> thank you for trying, we will provide the patches, but I don't know what is the right procedure
> to do so.
>
> is it ok to post the patches applied on top tag v4.9.16  of kernel/git/stable/linux-stable.git ?
> to whom should I send them ?
>

Actually, it looks like the fixes tag is not accurate, the bug is exposed only
with the new user control of CQE compression feature which should have
took care of
those issues, 9bcc86064bb5 ("net/mlx5e: Add CQE compression user control")
and this patch was only introduced in 4.10.

No need to apply those patches into 4.9-stable.

Sorry for the inconvenience.

thanks,
Saeed.
