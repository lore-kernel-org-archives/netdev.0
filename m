From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH-v2] sctp: user perfect name for Delayed SACK Timer option
Date: Wed, 19 Jan 2011 08:37:08 -0500
Message-ID: <4D36E904.4050609@hp.com>
References: <4D3693CA.40508@cn.fujitsu.com> <4D36A324.4040307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	=?UTF-8?B?6a2P5YuH5Yab?= <yjwei@cn.fujitsu.com>,
	Network-Maillist <netdev@vger.kernel.org>,
	SCTP-Maillist <linux-sctp@vger.kernel.org>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:8805 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389Ab1ASNho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 08:37:44 -0500
In-Reply-To: <4D36A324.4040307@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2011 03:39 AM, Shan Wei wrote:
> The option name of Delayed SACK Timer should be SCTP_DELAYED_SACK,
> not SCTP_DELAYED_ACK.
>=20
> Left SCTP_DELAYED_ACK be concomitant with SCTP_DELAYED_SACK,
> for making compatibility with existing applications.
>=20
> Reference:
> 8.1.19.  Get or Set Delayed SACK Timer (SCTP_DELAYED_SACK)
> =EF=BC=88http://tools.ietf.org/html/draft-ietf-tsvwg-sctpsocket-25)
>=20

this one much better.

Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

-vlad

> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
> ---
>  include/net/sctp/user.h |    1 +
>  net/sctp/socket.c       |    4 ++--
>  2 files changed, 3 insertions(+), 2 deletions(-)
>=20
> diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
> index 2b2769c..92eedc0 100644
> --- a/include/net/sctp/user.h
> +++ b/include/net/sctp/user.h
> @@ -78,6 +78,7 @@ typedef __s32 sctp_assoc_t;
>  #define SCTP_GET_PEER_ADDR_INFO	15
>  #define SCTP_DELAYED_ACK_TIME	16
>  #define SCTP_DELAYED_ACK SCTP_DELAYED_ACK_TIME
> +#define SCTP_DELAYED_SACK SCTP_DELAYED_ACK_TIME
>  #define SCTP_CONTEXT	17
>  #define SCTP_FRAGMENT_INTERLEAVE	18
>  #define SCTP_PARTIAL_DELIVERY_POINT	19 /* Set/Get partial delivery p=
oint */
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index a09b0dd..8e02550 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -3428,7 +3428,7 @@ SCTP_STATIC int sctp_setsockopt(struct sock *sk=
, int level, int optname,
>  		retval =3D sctp_setsockopt_peer_addr_params(sk, optval, optlen);
>  		break;
> =20
> -	case SCTP_DELAYED_ACK:
> +	case SCTP_DELAYED_SACK:
>  		retval =3D sctp_setsockopt_delayed_ack(sk, optval, optlen);
>  		break;
>  	case SCTP_PARTIAL_DELIVERY_POINT:
> @@ -5333,7 +5333,7 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk=
, int level, int optname,
>  		retval =3D sctp_getsockopt_peer_addr_params(sk, len, optval,
>  							  optlen);
>  		break;
> -	case SCTP_DELAYED_ACK:
> +	case SCTP_DELAYED_SACK:
>  		retval =3D sctp_getsockopt_delayed_ack(sk, len, optval,
>  							  optlen);
>  		break;

