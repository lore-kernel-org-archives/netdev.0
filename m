From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH] net: add comment for sock_efree() usage
Date: Tue, 10 Mar 2015 11:32:22 -0700
Message-ID: <54FF38B6.3080906@redhat.com>
References: <1426010626-6482-1-git-send-email-socketcan@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com
To: Oliver Hartkopp <socketcan@hartkopp.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59123 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752225AbbCJSca (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 14:32:30 -0400
In-Reply-To: <1426010626-6482-1-git-send-email-socketcan@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/10/2015 11:03 AM, Oliver Hartkopp wrote:
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
> ---
>   net/core/sock.c | 4 ++++
>   1 file changed, 4 insertions(+)
>
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 93c8b20..78e89eb 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1655,6 +1655,10 @@ void sock_rfree(struct sk_buff *skb)
>   }
>   EXPORT_SYMBOL(sock_rfree);
>   
> +/*
> + * Buffer destructor for skbs that are not used directly in read or write
> + * path, e.g. for error handler skbs. Automatically called from kfree_skb.
> + */
>   void sock_efree(struct sk_buff *skb)
>   {
>   	sock_put(skb->sk);

Acked-by: Alexander Duyck <alexander.h.duyck@redhat.com>
