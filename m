From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v7 net-next 01/13] vxlan: Move gro_cells_init to ndo_init
Date: Fri, 27 Oct 2017 17:58:57 -0700
Message-ID: <1509152337.11887.39.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171028000937.2631-1-tom@quantonium.net>
         <20171028000937.2631-2-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, pablo@netfilter.org, laforge@gnumonks.org,
        aschultz@tpip.net, netdev@vger.kernel.org, rohit@quantonium.net
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:57037 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751199AbdJ1A7B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 20:59:01 -0400
Received: by mail-pf0-f193.google.com with SMTP id b85so6051910pfj.13
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 17:59:01 -0700 (PDT)
In-Reply-To: <20171028000937.2631-2-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-10-27 at 17:09 -0700, Tom Herbert wrote:
> Move gro_cells_init to ndo_init and properly check return value.
> 
> Signed-off-by: Tom Herbert <tom@quantonium.net>
> ---
>  drivers/net/vxlan.c | 11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)


Reported-by: Eric Dumazet <edumazet@google.com>
