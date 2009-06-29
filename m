From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] sctp: xmit sctp packet always return no route error
Date: Mon, 29 Jun 2009 13:14:57 +0200
Message-ID: <4A48A231.3040805@cosmosbay.com>
References: <4A488021.50002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46407 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbZF2LPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 07:15:38 -0400
In-Reply-To: <4A488021.50002@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wei Yongjun a =A8=A6crit :
> Commit 'net: skb->dst accessors'(adf30907d63893e4208dfe3f5c88ae12bc2f=
25d5)
> broken the sctp protocol stack, the sctp packet can never be sent out=
 after
> Eric Dumazet's patch, which have typo in the sctp code.
>=20
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Oops, sorry !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

> ---
>  net/sctp/output.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index b764114..b94c211 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -407,7 +407,7 @@ int sctp_packet_transmit(struct sctp_packet *pack=
et)
>  	}
>  	dst =3D dst_clone(tp->dst);
>  	skb_dst_set(nskb, dst);
> -	if (dst)
> +	if (!dst)
>  		goto no_route;
> =20
>  	/* Build the SCTP header.  */

