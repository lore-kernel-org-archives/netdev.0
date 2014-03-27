From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: nlmon: flag nlmon devs with LLTX/SG
Date: Thu, 27 Mar 2014 09:09:23 -0700
Message-ID: <1395936563.12610.303.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395934499-29092-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:55592 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755729AbaC0QJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 12:09:25 -0400
Received: by mail-pb0-f51.google.com with SMTP id uo5so3695870pbc.38
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 09:09:25 -0700 (PDT)
In-Reply-To: <1395934499-29092-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-27 at 16:34 +0100, Daniel Borkmann wrote:
> As in xmit path we merely update statistics and free the skb, we
> can mark the device with LLTX feature, so that upper layers can
> avoid taking the single txq lock on xmit. While at it, also add
> missing NETIF_F_SG.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  drivers/net/nlmon.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

Acked-by: Eric Dumazet <edumazet@google.com>
