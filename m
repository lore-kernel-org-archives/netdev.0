From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] ipv6: Fix regression caused by efe4208 in
 udp_v6_mcast_next()
Date: Thu, 29 May 2014 13:37:35 -0700
Message-ID: <1401395855.3645.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1401395226-10304-1-git-send-email-sven.wegener@stealer.net>
	 <1401395226-10304-2-git-send-email-sven.wegener@stealer.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Sven Wegener <sven.wegener@stealer.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:59071 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbaE2Uhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 16:37:37 -0400
Received: by mail-pd0-f181.google.com with SMTP id z10so135488pdj.40
        for <netdev@vger.kernel.org>; Thu, 29 May 2014 13:37:37 -0700 (PDT)
In-Reply-To: <1401395226-10304-2-git-send-email-sven.wegener@stealer.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-29 at 20:27 +0000, Sven Wegener wrote:
> Commit efe4208 ("ipv6: make lookups simpler and faster") introduced a
> regression in udp_v6_mcast_next(), resulting in multicast packets not
> reaching the destination sockets under certain conditions.
> 
> The packet's IPv6 addresses are wrongly compared to the IPv6 addresses
> from the function's socket argument, which indicates the starting point
> for looping, instead of the loop variable. If the addresses from the
> first socket do not match the packet's addresses, no socket in the list
> will match.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: stable@vger.kernel.org # 3.13+
> Signed-off-by: Sven Wegener <sven.wegener@stealer.net>
> ---
>  net/ipv6/udp.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

I removed the CC stable@ , as you should not have use it.

Thanks
