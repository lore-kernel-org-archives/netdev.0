From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3] net: unix: Align send data_len up to
 PAGE_SIZE
Date: Thu, 15 May 2014 10:39:25 -0700
Message-ID: <1400175565.7973.146.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400169388.3782.35.camel@tkhai>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Kirill Tkhai <ktkhai@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:42327 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755200AbaEORj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 13:39:27 -0400
Received: by mail-pb0-f51.google.com with SMTP id ma3so1391829pbc.10
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 10:39:27 -0700 (PDT)
In-Reply-To: <1400169388.3782.35.camel@tkhai>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-15 at 19:56 +0400, Kirill Tkhai wrote:
> Using whole of allocated pages reduces requested skb->data size.
> This is just a little more thriftily allocation.
>     
> netperf does not show difference with the current performance.
>     
> Signed-off-by: Kirill Tkhai <ktkhai@parallels.com>
> ---
>  net/unix/af_unix.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)

Acked-by: Eric Dumazet <edumazet@google.com>
