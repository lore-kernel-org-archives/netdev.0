From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net/mlx4_en: reception NAPI/IRQ race breaker
Date: Sun, 26 Feb 2017 10:03:04 -0800
Message-ID: <1488132184.9415.157.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG-OcTAKkRQQHXV=8N-m+yATaX76UpGE4eWgK_8N52YePg@mail.gmail.com>
         <1488130457.9415.153.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488130836.9415.155.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33412 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750911AbdBZSLX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 13:11:23 -0500
Received: by mail-pg0-f66.google.com with SMTP id 5so10083660pgj.0
        for <netdev@vger.kernel.org>; Sun, 26 Feb 2017 10:11:00 -0800 (PST)
In-Reply-To: <1488130836.9415.155.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-02-26 at 09:40 -0800, Eric Dumazet wrote:
> NAPI_STATE_SCHED
> 
> Actually we could use an additional bit for that, that the driver would
> set even if NAPI_STATE_SCHED could not be grabbed.

Just to be clear :

Drivers would require no change, this would be done in
existing helpers.
