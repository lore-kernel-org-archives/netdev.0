From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC v2 04/12] ah6: Use the IPsec protocol multiplexer
 API
Date: Wed, 05 Mar 2014 18:54:01 +0400
Message-ID: <53173A89.40405@cogentembedded.com>
References: <1394023276-2591-1-git-send-email-steffen.klassert@secunet.com> <1394023276-2591-5-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christophe Gouault <christophe.gouault@6wind.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:64825 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932495AbaCEOx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 09:53:58 -0500
Received: by mail-la0-f54.google.com with SMTP id mc6so758452lab.41
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 06:53:57 -0800 (PST)
In-Reply-To: <1394023276-2591-5-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05-03-2014 16:41, Steffen Klassert wrote:

> Switch ah6 to use the new IPsec protocol multiplexer.

> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>   net/ipv6/ah6.c |   22 +++++++++++++++-------
>   1 file changed, 15 insertions(+), 7 deletions(-)
>
> diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
> index 6c5f094..f35911e 100644
> --- a/net/ipv6/ah6.c
> +++ b/net/ipv6/ah6.c
> @@ -643,7 +643,7 @@ out:
>   	return err;
>   }
>
> -static void ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
> +static int ah6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
>   		    u8 type, u8 code, int offset, __be32 info)

    You should realign this line to start under *struct*.

WBR, Sergei
