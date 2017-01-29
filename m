From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next V2 0/8] mlx4 misc improvements
Date: Sun, 29 Jan 2017 15:45:51 +0200
Message-ID: <edf492bb-dcf3-8faf-27be-a17e58a05abb@gmail.com>
References: <1485688950-32443-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33237 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751110AbdA2Nyf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 08:54:35 -0500
Received: by mail-wm0-f66.google.com with SMTP id v77so9716482wmv.0
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 05:54:01 -0800 (PST)
In-Reply-To: <1485688950-32443-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 29/01/2017 1:22 PM, Tariq Toukan wrote:
> Hi Dave,
>
> This patchset contains several improvements and cleanups
> from the team to the mlx4 Eth and core drivers.
>
> Series generated against net-next commit:
> 4e8f2fc1a55d Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
>
> Thanks,
> Tariq.
>
> v2:
> * Patch 1/9: used EOPNOTSUPP and not ENOTSUPP.
> * Patch 3/9: dropped, to be submitted separately in the future.
> * Patch 6/9: updated commit message.
Commit message update was not actually applied. I'm sending a re-spin soon.

Thanks,
Tariq
>
> Alaa Hleihel (1):
>    net/mlx4_core: Get num_tc using netdev_get_num_tc
>
> Ariel Levkovich (1):
>    net/mlx4_en: Adding support of turning off link autonegotiation via
>      ethtool
>
> Matan Barak (1):
>    net/mlx4_core: Add resource alloc/dealloc debugging
>
> Shaker Daibes (3):
>    net/mlx4_en: Pass user MTU value to Firmware at set port command
>    net/mlx4_en: Check the enabling mtu flag in SET_PORT wrapper flow
>    net/mlx4_en: Check the enabling pptx/pprx flags in SET_PORT wrapper
>      flow
>
> Tariq Toukan (1):
>    net/mlx4: Replace ENOSYS with better fitting error codes
>
> Yishai Hadas (1):
>    net/mlx4_core: Device revision support
>
>   drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    |  28 +++-
>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   8 +
>   drivers/net/ethernet/mellanox/mlx4/en_port.h       |   1 -
>   drivers/net/ethernet/mellanox/mlx4/en_tx.c         |   2 +-
>   drivers/net/ethernet/mellanox/mlx4/fw.c            |   6 +-
>   drivers/net/ethernet/mellanox/mlx4/main.c          |   6 +-
>   drivers/net/ethernet/mellanox/mlx4/mlx4.h          |  11 +-
>   drivers/net/ethernet/mellanox/mlx4/port.c          | 170 ++++++++++++++++-----
>   .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  51 ++++++-
>   include/linux/mlx4/device.h                        |   8 +-
>   10 files changed, 228 insertions(+), 63 deletions(-)
>
