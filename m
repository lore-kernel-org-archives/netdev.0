From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next] tcp: Check daddr_cache before use in tracepoint
Date: Tue, 17 Oct 2017 09:32:23 -0600
Message-ID: <f0320a62-708b-6b7c-bf58-23b9e8df6cdc@gmail.com>
References: <1508189387-27931-1-git-send-email-dsahern@gmail.com>
 <1508211908.31614.90.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:49685 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755171AbdJQPcW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 11:32:22 -0400
Received: by mail-pg0-f51.google.com with SMTP id g6so1697646pgn.6
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 08:32:22 -0700 (PDT)
In-Reply-To: <1508211908.31614.90.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/17 9:45 PM, Eric Dumazet wrote:
> IPV6 TCP uses sk->sk_v6_daddr and sk->->sk_v6_rcv_saddr

I moved v2 to those.

> So I would rather remove the need to fetch np = inet6_sk(sk) in the
> first place, and look at sk->sk_family instead.

I'll spin a v3 with that change.
