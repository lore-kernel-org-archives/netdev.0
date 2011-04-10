From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] net: sky2: convert to hw_features
Date: Sun, 10 Apr 2011 13:50:07 -0700
Message-ID: <20110410135007.7a4eccdf@nehalam>
References: <20110410131321.8CD9713A64@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43596 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754947Ab1DJUuP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Apr 2011 16:50:15 -0400
In-Reply-To: <20110410131321.8CD9713A64@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 10 Apr 2011 15:13:21 +0200 (CEST)
Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl> wrote:

> @@ -4620,18 +4574,21 @@ static __devinit struct net_device *sky2_init=
_netdev(struct sky2_hw *hw,
> =20
>  	sky2->port =3D port;
> =20
> -	dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_SG
> -		| NETIF_F_TSO | NETIF_F_GRO;
> +	dev->hw_features |=3D NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO;
> =20

You lost GRO flag in the conversion. Since code calls gro_receive,
this is necessary.

--=20
