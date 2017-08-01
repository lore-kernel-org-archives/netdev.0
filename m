From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/3] tcp: introduce tcp_rto_delta_us() helper for
 xmit timer fix
Date: Tue, 01 Aug 2017 00:16:28 -0700
Message-ID: <1501571788.1876.25.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170801025814.31206-1-ncardwell@google.com>
         <20170801025814.31206-2-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:38489 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbdHAHQb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 03:16:31 -0400
Received: by mail-wr0-f195.google.com with SMTP id g32so596070wrd.5
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 00:16:30 -0700 (PDT)
In-Reply-To: <20170801025814.31206-2-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-07-31 at 22:58 -0400, Neal Cardwell wrote:
> Pure refactor. This helper will be required in the xmit timer fix
> later in the patch series. (Because the TLP logic will want to make
> this calculation.)
> 
> Fixes: 6ba8a3b19e76 ("tcp: Tail loss probe (TLP)")
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Nandita Dukkipati <nanditad@google.com>
> ---
>  include/net/tcp.h    | 10 ++++++++++
>  net/ipv4/tcp_input.c |  5 +----
>  2 files changed, 11 insertions(+), 4 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
