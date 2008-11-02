From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] nets: clean up net/ipv4/*
Date: Sun, 02 Nov 2008 19:00:51 +0100
Message-ID: <490DEAD3.3030202@cosmosbay.com>
References: <20081102074446.GA12140@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jianjun Kong <jianjun@zeuux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:43125 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116AbYKBSBE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 13:01:04 -0500
In-Reply-To: <20081102074446.GA12140@ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jianjun Kong a =E9crit :
> clean up net/ipv4/* about code style.
>=20
> Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
>=20
> ---
>  net/ipv4/ah4.c                  |    4 +-
>  net/ipv4/arp.c                  |   18 +++---
>  net/ipv4/devinet.c              |   10 ++--
>  net/ipv4/esp4.c                 |    4 +-
>  net/ipv4/fib_frontend.c         |   10 ++--
>  net/ipv4/fib_hash.c             |   12 ++--
>  net/ipv4/fib_semantics.c        |    8 +-
>  net/ipv4/igmp.c                 |   46 +++++++-------
>  net/ipv4/inet_connection_sock.c |    2 +-
>  net/ipv4/inetpeer.c             |    2 +-
>  net/ipv4/ip_fragment.c          |    2 +-
>  net/ipv4/ip_gre.c               |   14 ++--
>  net/ipv4/ip_input.c             |    4 +-
>  net/ipv4/ip_output.c            |    6 +-
>  net/ipv4/ip_sockglue.c          |   32 +++++-----
>  net/ipv4/ipip.c                 |    2 +-
>  net/ipv4/ipmr.c                 |  130 +++++++++++++++++++----------=
---------
>  net/ipv4/raw.c                  |    8 +-
>  net/ipv4/route.c                |    6 +-
>  net/ipv4/tcp.c                  |    6 +-
>  net/ipv4/tcp_ipv4.c             |   16 +++---
>  net/ipv4/tcp_minisocks.c        |    2 +-
>  net/ipv4/tcp_output.c           |    8 +-
>  net/ipv4/tcp_timer.c            |    4 +-
>  net/ipv4/tcp_yeah.c             |    4 +-
>  net/ipv4/udp.c                  |   26 ++++----
>  net/ipv4/xfrm4_policy.c         |    2 +-
>  27 files changed, 194 insertions(+), 194 deletions(-)
>=20

Hello Jianun

=46or this kind of cleanup, you should probably base it on net-next-2.6

And on this tree, net/ipv4/udp.c already was changed, your patch wont a=
pply.

Also, its hard to review such large patch, that easily can contain an e=
rror.

I am not sure you have to CC linux-kernel, I removed it from the list.

Thank you

> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 2095abc..45a6c7c 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -230,22 +230,22 @@ static struct sock *__udp4_lib_lookup(struct ne=
t *net, __be32 saddr,
>  			if (inet->rcv_saddr) {
>  				if (inet->rcv_saddr !=3D daddr)
>  					continue;
> -				score+=3D2;
> +				score +=3D 2;
>  			}
>  			if (inet->daddr) {
>  				if (inet->daddr !=3D saddr)
>  					continue;
> -				score+=3D2;
> +				score +=3D 2;
>  			}
>  			if (inet->dport) {
>  				if (inet->dport !=3D sport)
>  					continue;
> -				score+=3D2;
> +				score +=3D 2;
>  			}
>  			if (sk->sk_bound_dev_if) {
>  				if (sk->sk_bound_dev_if !=3D dif)
>  					continue;
> -				score+=3D2;
> +				score +=3D 2;
>  			}
>  			if (score =3D=3D 9) {
>  				result =3D sk;


