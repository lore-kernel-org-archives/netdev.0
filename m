From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: trivial: Remove nocache argument from
 tcp_v4_send_synack
Date: Sun, 18 Aug 2013 08:38:57 -0700
Message-ID: <1376840337.21329.41.camel@edumazet-glaptop>
References: <1376840078-6556-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:36678 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397Ab3HRPi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 11:38:58 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so3974405pbc.11
        for <netdev@vger.kernel.org>; Sun, 18 Aug 2013 08:38:58 -0700 (PDT)
In-Reply-To: <1376840078-6556-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-08-18 at 17:34 +0200, Christoph Paasch wrote:
> The nocache-argument was used in tcp_v4_send_synack as an argument to
> inet_csk_route_req. However, since ba3f7f04ef2b (ipv4: Kill
> FLOWI_FLAG_RT_NOCACHE and associated code.) this is no more used.
> 
> This patch removes the unsued argument from tcp_v4_send_synack.
> 
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>  net/ipv4/tcp_ipv4.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
