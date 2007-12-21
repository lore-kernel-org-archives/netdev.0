From: Joe Perches <joe@perches.com>
Subject: Re: [TCP]: Convert several length variable to unsigned.
Date: Fri, 21 Dec 2007 06:17:31 -0800
Message-ID: <1198246651.6183.121.camel@localhost>
References: <20071221.164811.126977620.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2516 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753936AbXLUORz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 09:17:55 -0500
In-Reply-To: <20071221.164811.126977620.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2007-12-21 at 16:48 +0900, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=
=E8=8B=B1=E6=98=8E wrote:
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 93980c3..3b4169c 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -985,7 +985,7 @@ static void tcp_v6_send_reset(struct sock *sk, st=
ruct sk_buff *skb)
>  	struct tcphdr *th =3D tcp_hdr(skb), *t1;
>  	struct sk_buff *buff;
>  	struct flowi fl;
> -	int tot_len =3D sizeof(*th);
> +	unsigned int tot_len =3D sizeof(*th);
>  #ifdef CONFIG_TCP_MD5SIG
>  	struct tcp_md5sig_key *key;
>  #endif
> @@ -1085,7 +1085,7 @@ static void tcp_v6_send_ack(struct tcp_timewait=
_sock *tw,
>  	struct tcphdr *th =3D tcp_hdr(skb), *t1;
>  	struct sk_buff *buff;
>  	struct flowi fl;
> -	int tot_len =3D sizeof(struct tcphdr);
> +	unsigned int tot_len =3D sizeof(struct tcphdr);
>  	__be32 *topt;
>  #ifdef CONFIG_TCP_MD5SIG
>  	struct tcp_md5sig_key *key;

Unrelated, but perhaps tot_len should be initialized in
a consistent fashion?

I think unsigned int tot_len =3D sizeof(struct tcphdr); is more readabl=
e.

