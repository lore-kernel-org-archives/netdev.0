From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH ipsec v2 3/3] xfrm: choose protocol family by skb
 protocol
Date: Sun, 18 Aug 2013 08:48:21 -0700
Message-ID: <1376840901.21329.47.camel@edumazet-glaptop>
References: <20130818114701.GA10270@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
	edumazet@google.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33386 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752015Ab3HRPsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 11:48:23 -0400
Received: by mail-pd0-f169.google.com with SMTP id r10so4082324pdi.28
        for <netdev@vger.kernel.org>; Sun, 18 Aug 2013 08:48:23 -0700 (PDT)
In-Reply-To: <20130818114701.GA10270@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-08-18 at 13:47 +0200, Hannes Frederic Sowa wrote:
> We need to choose the protocol family by skb->protocol. Otherwise we
> call the wrong xfrm{4,6}_local_error handler in case an ipv6 sockets is
> used in ipv4 mode, in which case we should call down to xfrm4_local_error
> (ip6 sockets are a superset of ip4 ones).
> 
> We are called before before ip_output functions, so skb->protocol is
> not reset.
> 
> v2:
> a) unchanged
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Acked-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

Hi Hannes

For your next patches, please add the v1/v2/v3 stuff _after_ the ---
separator as in :

Normal changelog (will be included in git history)

Signed-off-by: ....
Cc: ...
---
v2: Fix (you can omit this line if there was no change between v2 and
v1)
 diffstat
 diff


This is to have clean changelogs, with high S/N ratio ;)

Thanks !
