From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: tcp: move GRO/GSO functions to
 tcp_offload
Date: Fri, 07 Jun 2013 08:39:11 -0700
Message-ID: <1370619551.24311.426.camel@edumazet-glaptop>
References: <1370617906-4849-1-git-send-email-dborkman@redhat.com>
	 <1370617906-4849-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:45644 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754584Ab3FGPjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 11:39:13 -0400
Received: by mail-pb0-f51.google.com with SMTP id um15so4793027pbc.24
        for <netdev@vger.kernel.org>; Fri, 07 Jun 2013 08:39:13 -0700 (PDT)
In-Reply-To: <1370617906-4849-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-07 at 17:11 +0200, Daniel Borkmann wrote:
> Would be good to make things explicit and move those functions to
> a new file called tcp_offload.c, thus make this similar to tcpv6_offload.c.
> While moving all related functions into tcp_offload.c, we can also
> make some of them static, since they are only used there. Also, add
> an explicit registration function.
> 
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  I'll also follow-up with a udp_offload.c very soon after we agreed on this one.

LGTM, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
