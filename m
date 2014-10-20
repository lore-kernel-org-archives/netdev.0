From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/7] netfilter: missing module license in the nf_reject_ipvX
 modules
Date: Mon, 20 Oct 2014 14:49:35 +0400
Message-ID: <5444E8BF.20904@cogentembedded.com>
References: <1413792639-3954-1-git-send-email-pablo@netfilter.org> <1413792639-3954-2-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:57463 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753303AbaJTKti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 06:49:38 -0400
Received: by mail-lb0-f174.google.com with SMTP id p9so3612519lbv.19
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 03:49:37 -0700 (PDT)
In-Reply-To: <1413792639-3954-2-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/20/2014 12:10 PM, Pablo Neira Ayuso wrote:

> [   23.545204] nf_reject_ipv4: module license 'unspecified' taints kernel.

> Fixes: c8d7b98 ("netfilter: move nf_send_resetX() code to nf_reject_ipvX modules")
> Reported-by: Dave Young <dyoung@redhat.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>   net/ipv4/netfilter/nf_reject_ipv4.c |    3 +++
>   net/ipv6/netfilter/nf_reject_ipv6.c |    4 ++++
>   2 files changed, 7 insertions(+)

[...]
> diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
> index 5f5f043..20d9def 100644
> --- a/net/ipv6/netfilter/nf_reject_ipv6.c
> +++ b/net/ipv6/netfilter/nf_reject_ipv6.c
> @@ -5,6 +5,8 @@
>    * it under the terms of the GNU General Public License version 2 as
>    * published by the Free Software Foundation.
>    */
> +
> +#include <linux/module.h>
>   #include <net/ipv6.h>
>   #include <net/ip6_route.h>
>   #include <net/ip6_fib.h>
> @@ -161,3 +163,5 @@ void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
>   		ip6_local_out(nskb);
>   }
>   EXPORT_SYMBOL_GPL(nf_send_reset6);
> +
> +MODULE_LICENSE("GPL");

    Actually, "GPL v2" as follows from the comment above.

WBR, Sergei
