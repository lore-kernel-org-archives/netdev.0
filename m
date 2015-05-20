From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/4] net: make skb_splice_bits more
 configureable
Date: Wed, 20 May 2015 16:43:16 -0700
Message-ID: <1432165396.4060.58.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1432135413.git.hannes@stressinduktion.org>
	 <a464064d180a10d904409aa21388288d1faf7a4d.1432135413.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:37272 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754433AbbETXnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 19:43:18 -0400
Received: by igbsb11 with SMTP id sb11so52567110igb.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 16:43:17 -0700 (PDT)
In-Reply-To: <a464064d180a10d904409aa21388288d1faf7a4d.1432135413.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-20 at 17:35 +0200, Hannes Frederic Sowa wrote:
> Prepare skb_splice_bits to be able to deal with AF_UNIX sockets.
> 
> AF_UNIX sockets don't use lock_sock/release_sock and thus we have to
> use a callback to make the locking and unlocking configureable.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  include/linux/skbuff.h | 11 +++++++++--
>  net/core/skbuff.c      | 45 ++++++++++++++++++++++++++++-----------------
>  net/ipv4/tcp.c         |  5 +++--
>  3 files changed, 40 insertions(+), 21 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
