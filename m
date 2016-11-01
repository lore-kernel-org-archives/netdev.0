From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] mlxsw: switchib: Remove unused including
 <generated/utsrelease.h>
Date: Tue, 1 Nov 2016 16:44:49 +0100
Message-ID: <20161101154449.GC1677@nanopsycho.orion>
References: <1478013248-9409-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>,
        Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34092 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbcKAPov (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 11:44:51 -0400
Received: by mail-wm0-f67.google.com with SMTP id p190so16984268wmp.1
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 08:44:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1478013248-9409-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Nov 01, 2016 at 04:14:08PM CET, weiyj.lk@gmail.com wrote:
>From: Wei Yongjun <weiyongjun1@huawei.com>
>
>Remove including <generated/utsrelease.h> that don't need it.
>
>Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
>---
> drivers/net/ethernet/mellanox/mlxsw/switchib.c | 1 -
> 1 file changed, 1 deletion(-)
>
>diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchib.c b/drivers/net/ethernet/mellanox/mlxsw/switchib.c
>index ec0b27e..1552594 100644
>--- a/drivers/net/ethernet/mellanox/mlxsw/switchib.c
>+++ b/drivers/net/ethernet/mellanox/mlxsw/switchib.c
>@@ -43,7 +43,6 @@
> #include <linux/skbuff.h>
> #include <linux/if_vlan.h>
> #include <net/switchdev.h>
>-#include <generated/utsrelease.h>

I believe it is not needed so spectrum.c and switchx2.x. Would you
please extend your patch to remove from there as well? Thanks.
