From: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont <remi@remlab.net>
Subject: Re: [PATCH v2 1/2] net: phonet: mark header_ops as const
Date: Sat, 30 Sep 2017 14:49:09 +0300
Message-ID: <44317731.eALDOE0hdk@philogene>
References: <1506764376-6549-1-git-send-email-xiaolou4617@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net, netdev@vger.kernel.org, courmisch@gmail.com
To: Lin Zhang <xiaolou4617@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns207790.ip-94-23-215.eu ([94.23.215.26]:57391 "EHLO
        ns207790.ip-94-23-215.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751677AbdI3L4t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 07:56:49 -0400
In-Reply-To: <1506764376-6549-1-git-send-email-xiaolou4617@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On samedi 30 septembre 2017 17:39:36 EEST Lin Zhang wrote:
> Signed-off-by: Lin Zhang <xiaolou4617@gmail.com>
> ---
>  net/phonet/af_phonet.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
> index f925753..b12142e 100644
> --- a/net/phonet/af_phonet.c
> +++ b/net/phonet/af_phonet.c
> @@ -149,7 +149,7 @@ static int pn_header_parse(const struct sk_buff *skb,
> unsigned char *haddr) return 1;
>  }
> 
> -struct header_ops phonet_header_ops = {
> +const struct header_ops phonet_header_ops = {
>  	.create = pn_header_create,
>  	.parse = pn_header_parse,
>  };

Acked-by: Rémi Denis-Courmont <remi@remlab.net>


-- 
Rémi Denis-Courmont
