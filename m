From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v1] mlx4: remove unused fields
Date: Wed, 28 Sep 2016 11:19:07 -0700
Message-ID: <1475086747.28155.112.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1475085604-101493-1-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yishai Hadas <yishaih@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
        edumazet@google.com, David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33599 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753895AbcI1STK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 14:19:10 -0400
In-Reply-To: <1475085604-101493-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-09-28 at 11:00 -0700, David Decotigny wrote:
> From: David Decotigny <decot@googlers.com>
> 
> This also can address following UBSAN warnings:
> [   36.640343] ================================================================================
> [   36.648772] UBSAN: Undefined behaviour in drivers/net/ethernet/mellanox/mlx4/fw.c:857:26
> [   36.656853] shift exponent 64 is too large for 32-bit type 'int'
> [   36.663348] ================================================================================
> [   36.671783] ================================================================================
> [   36.680213] UBSAN: Undefined behaviour in drivers/net/ethernet/mellanox/mlx4/fw.c:861:27
> [   36.688297] shift exponent 35 is too large for 32-bit type 'int'
> [   36.694702] ================================================================================
> 
> Tested:
>   reboot with UBSAN, no warning.
> 
> Signed-off-by: David Decotigny <decot@googlers.com>
> ---

CC: Tariq Toukan <tariqt@mellanox.com> (mlx4 maintainer)

Note this patch was cooked/tested using net-next, but can be applied to
net tree, with minor fuzz.

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks David.
