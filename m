From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/4] tcpv6: trivial formatting changes to
 send_(ack|reset)
Date: Thu, 09 Oct 2008 18:52:30 +0900 (JST)
Message-ID: <20081009.185230.46697834.yoshfuji@linux-ipv6.org>
References: <1223544937-12595-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1223544937-12595-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:56701 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756123AbYJIKQ6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 06:16:58 -0400
In-Reply-To: <1223544937-12595-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <1223544937-12595-2-git-send-email-ilpo.jarvinen@helsinki.fi=
> (at Thu,  9 Oct 2008 12:35:35 +0300), "Ilpo J=E4rvinen" <ilpo.jarvine=
n@helsinki.fi> says:

> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> ---
>  net/ipv6/tcp_ipv6.c |    7 +++----
>  1 files changed, 3 insertions(+), 4 deletions(-)
>=20
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 2084f5a..3f268a3 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -948,7 +948,7 @@ static void tcp_v6_send_reset(struct sock *sk, st=
ruct sk_buff *skb)
>  	struct flowi fl;
>  	struct net *net =3D dev_net(skb->dst->dev);
>  	struct sock *ctl_sk =3D net->ipv6.tcp_sk;
> -	unsigned int tot_len =3D sizeof(*th);
> +	unsigned int tot_len =3D sizeof(struct tcphdr);
>  #ifdef CONFIG_TCP_MD5SIG
>  	struct tcp_md5sig_key *key;
>  #endif

I usually prefer sizeof(var) (or sizeof(*ptr)) over sizeof(type).
Could you justify this change?

--yoshfuji
