From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH] tcp: md5: remove unneeded check in tcp_v4_parse_md5_keys
Date: Mon, 04 Aug 2014 09:05:55 +0900
Message-ID: <53DECE63.8070008@miraclelinux.com>
References: <20140803224519.49a40242da5c1cbe61f97753@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com
To: Dmitry Popov <ixaphire@qrator.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og115.obsmtp.com ([64.18.2.217]:37936 "HELO
	exprod7og115.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751871AbaHDAF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2014 20:05:59 -0400
Received: by mail-pa0-f50.google.com with SMTP id et14so8922698pad.37
        for <netdev@vger.kernel.org>; Sun, 03 Aug 2014 17:05:57 -0700 (PDT)
In-Reply-To: <20140803224519.49a40242da5c1cbe61f97753@qrator.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry Popov wrote:
> tcpm_key is an array inside struct tcp_md5sig, there is no need to check it
> against NULL.
>
> Signed-off-by: Dmitry Popov <ixaphire@qrator.net>

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

(IPv6 side is okay.)

> ---
>   net/ipv4/tcp_ipv4.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 77cccda..8ea4eff 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1064,7 +1064,7 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
>   	if (sin->sin_family != AF_INET)
>   		return -EINVAL;
>
> -	if (!cmd.tcpm_key || !cmd.tcpm_keylen)
> +	if (!cmd.tcpm_keylen)
>   		return tcp_md5_do_del(sk, (union tcp_md5_addr *)&sin->sin_addr.s_addr,
>   				      AF_INET);
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--yoshfuji
