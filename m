From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] tcp: Remove use of daddr_cache in tracepoint
Date: Tue, 17 Oct 2017 14:44:38 -0700
Message-ID: <1508276678.31614.118.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1508270973-23789-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:50466 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754359AbdJQVol (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 17:44:41 -0400
Received: by mail-it0-f66.google.com with SMTP id 72so4303762itl.5
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 14:44:40 -0700 (PDT)
In-Reply-To: <1508270973-23789-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-17 at 13:09 -0700, David Ahern wrote:
> Running perf in one window to capture tcp_retransmit_skb tracepoint:
>     $ perf record -e tcp:tcp_retransmit_skb -a
> 
> And causing a retransmission on an active TCP session (e.g., dropping
> packets in the receiver, changing MTU on the interface to 500 and back
> to 1500) triggers a panic:

> Remove use of ipv6_pinfo in favor of data in sock_common.
> 
> Fixes: e086101b150a ("tcp: add a tracepoint for tcp retransmission")
> Signed-off-by: David Ahern <dsahern@gmail.com>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>

Thanks David !
