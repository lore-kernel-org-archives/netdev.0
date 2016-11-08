From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 1/2] bnxt_en: do not call napi_hash_add()
Date: Tue, 8 Nov 2016 13:25:01 -0800
Message-ID: <CACKFLikWnyjL9ak2_OSLQmjW4N90biwwqx25keCP7nuDa3_x4A@mail.gmail.com>
References: <1478632013.17367.23.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f182.google.com ([209.85.217.182]:33088 "EHLO
        mail-ua0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754440AbcKHVZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 16:25:02 -0500
Received: by mail-ua0-f182.google.com with SMTP id 20so158315916uak.0
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2016 13:25:02 -0800 (PST)
In-Reply-To: <1478632013.17367.23.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 8, 2016 at 11:06 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> From: Eric Dumazet <edumazet@google.com>
>
> This is automatically done from netif_napi_add(), and we want to not
> export napi_hash_add() anymore in the following patch.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Michael Chan <michael.chan@broadcom.com>

Acked-by: Michael Chan <michael.chan@broadcom.com>
