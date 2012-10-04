From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [RFC PATCH 1/2] sctp: fix a typo in prototype of __sctp_rcv_lookup()
Date: Thu, 04 Oct 2012 13:04:16 -0400
Message-ID: <506DC190.6050407@gmail.com>
References: <1349279002-4008-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:35011 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392Ab2JDREU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 13:04:20 -0400
In-Reply-To: <1349279002-4008-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2012 11:43 AM, Nicolas Dichtel wrote:
> Just to avoid confusion when people only reads this prototype.
>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>   net/sctp/input.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index 25dfe73..8bd3c27 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -68,8 +68,8 @@
>   static int sctp_rcv_ootb(struct sk_buff *);
>   static struct sctp_association *__sctp_rcv_lookup(struct net *net,
>   				      struct sk_buff *skb,
> -				      const union sctp_addr *laddr,
>   				      const union sctp_addr *paddr,
> +				      const union sctp_addr *laddr,
>   				      struct sctp_transport **transportp);
>   static struct sctp_endpoint *__sctp_rcv_lookup_endpoint(struct net *net,
>   						const union sctp_addr *laddr);
>

Wow,  this must have been very old...

Acked-by: Vlad Yasevich <vyasevich@gmail.com>
