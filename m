From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v2 2/3] net: TCP thin linear timeouts
Date: Tue, 09 Feb 2010 07:31:59 +0100
Message-ID: <1265697119.4236.99.camel@edumazet-laptop>
References: <4B701EE2.1000006@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>,
	william.allen.simpson@gmail.com
To: Andreas Petlund <apetlund@simula.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B701EE2.1000006@simula.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 08 f=C3=A9vrier 2010 =C3=A0 15:25 +0100, Andreas Petlund a =C3=
=A9crit :
> =20
> +	case TCP_THIN_LT:
> +		if (val)
> +			tp->thin_lt =3D 1;
> +		break;
> +

Why not allowing user to clear thin_lt ?
