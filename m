From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net] : add a missing rcu synchronization
Date: Wed, 16 Nov 2016 07:59:55 -0800
Message-ID: <CACKFLiniozU+O94hH+HmF7B8-BK=+oFZyoiRtA1x2A6jj9aNvA@mail.gmail.com>
References: <1479306712.8455.185.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f41.google.com ([209.85.213.41]:35616 "EHLO
        mail-vk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752194AbcKPP75 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 10:59:57 -0500
Received: by mail-vk0-f41.google.com with SMTP id w194so118207697vkw.2
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 07:59:57 -0800 (PST)
In-Reply-To: <1479306712.8455.185.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2016 at 6:31 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Add a missing synchronize_net() call to avoid potential use after free,
> since we explicitly call napi_hash_del() to factorize the RCU grace
> period.
>
> Fixes: c0c050c58d84 ("bnxt_en: New Broadcom ethernet driver.")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Michael Chan <michael.chan@broadcom.com>

Thanks.  Subject line is missing the driver name.  Other than that,

Acked-by: Michael Chan <michael.chan@broadcom.com>
