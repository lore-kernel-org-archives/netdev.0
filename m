From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/ipv4/tcp_input.c: fix compilation breakage when
 FASTRETRANS_DEBUG > 1
Date: Mon, 31 May 2010 23:32:05 +0200
Message-ID: <1275341525.2478.28.camel@edumazet-laptop>
References: <1275330055.14079.8.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50169 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751028Ab0EaVcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 17:32:09 -0400
Received: by wyi11 with SMTP id 11so526687wyi.19
        for <netdev@vger.kernel.org>; Mon, 31 May 2010 14:32:07 -0700 (PDT)
In-Reply-To: <1275330055.14079.8.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 31 mai 2010 =C3=A0 11:20 -0700, Joe Perches a =C3=A9crit :
> Commit: c720c7e8383aff1cb219bddf474ed89d850336e3 missed these.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

>  net/ipv4/tcp_input.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 3e6dafc..548d575 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2639,7 +2639,7 @@ static void DBGUNDO(struct sock *sk, const char=
 *msg)
>  	if (sk->sk_family =3D=3D AF_INET) {
>  		printk(KERN_DEBUG "Undo %s %pI4/%u c%u l%u ss%u/%u p%u\n",
>  		       msg,
> -		       &inet->daddr, ntohs(inet->dport),
> +		       &inet->inet_daddr, ntohs(inet->inet_dport),
>  		       tp->snd_cwnd, tcp_left_out(tp),
>  		       tp->snd_ssthresh, tp->prior_ssthresh,
>  		       tp->packets_out);
> @@ -2649,7 +2649,7 @@ static void DBGUNDO(struct sock *sk, const char=
 *msg)
>  		struct ipv6_pinfo *np =3D inet6_sk(sk);
>  		printk(KERN_DEBUG "Undo %s %pI6/%u c%u l%u ss%u/%u p%u\n",
>  		       msg,
> -		       &np->daddr, ntohs(inet->dport),
> +		       &np->daddr, ntohs(inet->inet_dport),
>  		       tp->snd_cwnd, tcp_left_out(tp),
>  		       tp->snd_ssthresh, tp->prior_ssthresh,
>  		       tp->packets_out);
>=20
>=20


