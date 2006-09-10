From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH]:[XFRM] BEET mode
Date: Mon, 11 Sep 2006 08:53:09 +0900 (JST)
Message-ID: <20060911.085309.00654005.yoshfuji@linux-ipv6.org>
References: <1157908206.450446ee9d523@webmail.hiit.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.apana.org.au, miika@iki.fi, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:25104 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S964828AbWIJXvI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Sep 2006 19:51:08 -0400
To: Diego.Beltrami@hiit.fi
In-Reply-To: <1157908206.450446ee9d523@webmail.hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <1157908206.450446ee9d523@webmail.hiit.fi> (at Sun, 10 Sep 2006 20:10:06 +0300), Diego Beltrami <Diego.Beltrami@hiit.fi> says:

> as part of this email you can find a patch which introduces the BEET mode (Bound
> End-to-End Tunnel) as specified by the ietf draft at the following link:
:

> Signed-off-by: Diego Beltrami <diego.beltrami@gmail.com>
>                Miika Komu     <miika@iki.fi>
>                Herbert Xu     <herbert@gondor.apana.org.au>
>                Abhinav Pathak <abhinav.pathak@hiit.fi>
>                Jeff Ahrenholz <ahrenholz@gmail.com>

Please put one "Signed-off-by:" per person,.

> diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
> index 46a15c7..6a616de 100644
> --- a/include/linux/xfrm.h
> +++ b/include/linux/xfrm.h
> @@ -120,7 +120,8 @@ enum
> 
>  #define XFRM_MODE_TRANSPORT 0
>  #define XFRM_MODE_TUNNEL 1
> -#define XFRM_MODE_MAX 2
> +#define XFRM_MODE_BEET 2
> +#define XFRM_MODE_MAX 3
> 
>  /* Netlink configuration messages.  */
>  enum {

This clearly indicates that this patch conflicts with current net-2.6.19.
Please rebase to the current tree.

--yoshfuji
