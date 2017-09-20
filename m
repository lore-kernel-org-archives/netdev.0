From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH,net-next,1/2] tun: enable NAPI for TUN/TAP driver
Date: Tue, 19 Sep 2017 19:51:28 -0700
Message-ID: <1505875888.29839.80.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170919073402.2292-1-peterpenkov96@gmail.com>
         <20170919073402.2292-2-peterpenkov96@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Willem de Bruijn <willemb@google.com>, davem@davemloft.net,
        ppenkov@stanford.edu
To: Petar Penkov <peterpenkov96@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:53082 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751016AbdITCvb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 22:51:31 -0400
Received: by mail-pf0-f177.google.com with SMTP id p87so830331pfj.9
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 19:51:31 -0700 (PDT)
In-Reply-To: <20170919073402.2292-2-peterpenkov96@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-09-19 at 00:34 -0700, Petar Penkov wrote:
> Changes TUN driver to use napi_gro_receive() upon receiving packets
> rather than netif_rx_ni(). Adds flag CONFIG_TUN_NAPI that enables
> these changes and operation is not affected if the flag is disabled.
> SKBs are constructed upon packet arrival and are queued to be
> processed later.
> 

> 
> Signed-off-by: Petar Penkov <peterpenkov96@gmail.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Mahesh Bandewar <maheshb@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: davem@davemloft.net
> Cc: ppenkov@stanford.edu
> ---

Very nice, thanks a lot Petar.

Acked-by: Eric Dumazet <edumazet@google.com>
