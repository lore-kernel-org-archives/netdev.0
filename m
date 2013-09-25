From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ip_tunnel: Do not use stale inner_iph pointer.
Date: Wed, 25 Sep 2013 10:10:51 -0700
Message-ID: <1380129051.3165.158.camel@edumazet-glaptop>
References: <1380128267-16123-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:56628 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833Ab3IYRKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 13:10:53 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so6348092pdj.4
        for <netdev@vger.kernel.org>; Wed, 25 Sep 2013 10:10:53 -0700 (PDT)
In-Reply-To: <1380128267-16123-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-25 at 09:57 -0700, Pravin B Shelar wrote:
> While sending packet skb_cow_head() can change skb header which
> invalidates inner_iph pointer to skb header. Following patch
> avoid using it. Found by code inspection.
> 
> This bug was introduced by commit 0e6fbc5b6c6218 (ip_tunnels: extend
> iptunnel_xmit()).
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  net/ipv4/ip_tunnel.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
