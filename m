From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] net: fix skb_page_frag_refill() kerneldoc
Date: Mon, 08 Sep 2014 15:04:28 +0400
Message-ID: <540D8D3C.9080202@cogentembedded.com>
References: <1410174000.11872.94.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:47200 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640AbaIHLEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 07:04:41 -0400
Received: by mail-la0-f49.google.com with SMTP id b17so17318165lan.36
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 04:04:37 -0700 (PDT)
In-Reply-To: <1410174000.11872.94.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/8/2014 3:00 PM, Eric Dumazet wrote:

> From: Eric Dumazet <edumazet@google.com>

> In commit d9b2938aabf7 ("net: attempt a single high order allocation)
> I forgot to update kerneldoc, as @prio parameter was renamed to @gfp

> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>   net/core/sock.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

> diff --git a/net/core/sock.c b/net/core/sock.c
> index d372b4bd3f99..9c3f823e76a9 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1866,7 +1866,7 @@ EXPORT_SYMBOL(sock_alloc_send_skb);
>    * skb_page_frag_refill - check that a page_frag contains enough room
>    * @sz: minimum size of the fragment we want to get
>    * @pfrag: pointer to page_frag
> - * @prio: priority for memory allocation
> + * @gfp: priority for memory allocation

    'gfp' is not priority, it's just flags.

WBR, Sergei
