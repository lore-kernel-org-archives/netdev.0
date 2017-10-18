From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: Remove use of inet6_sk and add IPv6
 checks to tracepoint
Date: Wed, 18 Oct 2017 08:28:23 -0700
Message-ID: <1508340503.31614.120.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1508339849-19527-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        songliubraving@fb.com, davem@davemloft.net
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:50744 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750751AbdJRP20 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:28:26 -0400
Received: by mail-it0-f43.google.com with SMTP id 72so6698688itl.5
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 08:28:25 -0700 (PDT)
In-Reply-To: <1508339849-19527-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-10-18 at 08:17 -0700, David Ahern wrote:
> 386fd5da401d ("tcp: Check daddr_cache before use in tracepoint") was the
> second version of the tracepoint fixup patch. This patch is the delta
> between v2 and v3.  Specifically, remove the use of inet6_sk and check
> sk_family as requested by Eric and add IS_ENABLED(CONFIG_IPV6) around
> the use of sk_v6_rcv_saddr and sk_v6_daddr as done in sock_common (noted
> by Cong).
> 
> Signed-off-by: David Ahern <dsahern@gmail.com>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>

Thanks !
