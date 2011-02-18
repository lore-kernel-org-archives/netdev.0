From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch net-next-2.6] net: convert bonding to use rx_handler
Date: Fri, 18 Feb 2011 15:46:45 +0100
Message-ID: <4D5E8655.5070304@trash.net>
References: <20110218132524.GC2939@psychotron.redhat.com>	 <1298035791.6201.56.camel@edumazet-laptop>	 <20110218141456.GD2939@psychotron.redhat.com> <1298039252.6201.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	fubar@us.ibm.com, nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45144 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754369Ab1BROqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 09:46:49 -0500
In-Reply-To: <1298039252.6201.66.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 18.02.2011 15:27, schrieb Eric Dumazet:
> Le vendredi 18 f=C3=A9vrier 2011 =C3=A0 15:14 +0100, Jiri Pirko a =C3=
=A9crit :
>=20
>> Do not know how to do it better. As for percpu variable, not only
>> origdev would have to be remembered but also probably skb pointer to
>> know if it's the first run on the skb or not. Can't really figure ou=
t a
>> better solution. Can you?
>=20
> I'll try and let you know.

Why not simply do a lookup on skb->iif?
