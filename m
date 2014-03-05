From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC v2 03/12] esp6: Use the IPsec protocol multiplexer
 API
Date: Wed, 05 Mar 2014 18:52:12 +0400
Message-ID: <53173A1C.2070002@cogentembedded.com>
References: <1394023276-2591-1-git-send-email-steffen.klassert@secunet.com> <1394023276-2591-4-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christophe Gouault <christophe.gouault@6wind.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:52361 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758273AbaCEOwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 09:52:10 -0500
Received: by mail-la0-f54.google.com with SMTP id mc6so779929lab.13
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 06:52:09 -0800 (PST)
In-Reply-To: <1394023276-2591-4-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05-03-2014 16:41, Steffen Klassert wrote:

> Switch esp6 to use the new IPsec protocol multiplexer.

> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>   net/ipv6/esp6.c |   24 ++++++++++++++++--------
>   1 file changed, 16 insertions(+), 8 deletions(-)

> diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
> index 6eef8a7..ec6971f 100644
> --- a/net/ipv6/esp6.c
> +++ b/net/ipv6/esp6.c
> @@ -421,7 +421,7 @@ static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
>   		 net_adj) & ~(blksize - 1)) + net_adj - 2;
>   }
>
> -static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
> +static int esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
>   		     u8 type, u8 code, int offset, __be32 info)

    You should realign this line again to start under *struct*.

WBR, Sergei
