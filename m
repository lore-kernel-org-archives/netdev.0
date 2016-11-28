From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 0/6] tcp: sender chronographs instrumentation
Date: Mon, 28 Nov 2016 09:38:07 -0800
Message-ID: <1480354687.18162.67.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480316838-154141-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, soheil@google.com, francisyyan@gmail.com,
        netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36748 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750922AbcK1RjJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:39:09 -0500
Received: by mail-pg0-f66.google.com with SMTP id x23so13691714pgx.3
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 09:39:09 -0800 (PST)
In-Reply-To: <1480316838-154141-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-11-27 at 23:07 -0800, Yuchung Cheng wrote:
> This patch set provides instrumentation on TCP sender limitations.
> While developing the BBR congestion control, we noticed that TCP
> sending process is often limited by factors unrelated to congestion
> control: insufficient sender buffer and/or insufficient receive
> window/buffer to saturate the network bandwidth. Unfortunately these
> limits are not visible to the users and often the poor performance
> is attributed to the congestion control of choice.

For the whole series :

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
