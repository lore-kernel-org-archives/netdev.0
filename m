From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 3/3] tcp: fix xmit timer to only be reset if data
 ACKed/SACKed
Date: Tue, 01 Aug 2017 00:25:16 -0700
Message-ID: <1501572316.1876.32.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170801025814.31206-1-ncardwell@google.com>
         <20170801025814.31206-4-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:38709 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750763AbdHAHZT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 03:25:19 -0400
Received: by mail-wm0-f67.google.com with SMTP id y206so1653185wmd.5
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 00:25:18 -0700 (PDT)
In-Reply-To: <20170801025814.31206-4-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-07-31 at 22:58 -0400, Neal Cardwell wrote:
> Fix a TCP loss recovery performance bug raised recently on the netdev
> list, in two threads:
> 
> (i)  July 26, 2017: netdev thread "TCP fast retransmit issues"
> (ii) July 26, 2017: netdev thread:
>      "[PATCH V2 net-next] TLP: Don't reschedule PTO when there's one
>      outstanding TLP retransmission"

Acked-by: Eric Dumazet <edumazet@google.com>
