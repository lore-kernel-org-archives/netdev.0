From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] ipv6: introduce tcp_v6_iif()
Date: Fri, 17 Oct 2014 17:02:04 -0700
Message-ID: <CAHA+R7NLTKz1O3CJLoH9xn2u2J-k2XU_j6CuAkcCZbcayOhyGA@mail.gmail.com>
References: <1413562640.24953.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:54553 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbaJRACF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 20:02:05 -0400
Received: by mail-qc0-f171.google.com with SMTP id i17so1456215qcy.30
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 17:02:04 -0700 (PDT)
In-Reply-To: <1413562640.24953.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 17, 2014 at 9:17 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Commit 971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache line
> misses") added a regression for SO_BINDTODEVICE on IPv6.
>
> This is because we still use inet6_iif() which expects that IP6 control
> block is still at the beginning of skb->cb[]
>
> This patch adds tcp_v6_iif() helper and uses it where necessary.
>
> Because __inet6_lookup_skb() is used by TCP and DCCP, we add an iif
> parameter to it.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: 971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache line misses")

As I already explained in previous reply, this is probably the best solution
for net, so:

Acked-by: Cong Wang <cwang@twopensource.com>
