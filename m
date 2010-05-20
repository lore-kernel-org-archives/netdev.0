From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFC: netfilter: synproxy iptables target
Date: Thu, 20 May 2010 16:32:43 +0200
Message-ID: <1274365963.4046.39.camel@edumazet-laptop>
References: <AANLkTimp6S7MpwDAT8l-M0ZWjs2HIcUEfL5f8j9-QDZh@mail.gmail.com>
	 <4BF54310.6030004@trash.net>
	 <AANLkTimjY_0yKfMtAUxI7He-QH5R5AdDCR3V8eKSgbGq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimjY_0yKfMtAUxI7He-QH5R5AdDCR3V8eKSgbGq@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 20 mai 2010 =C3=A0 22:21 +0800, Changli Gao a =C3=A9crit :

>=20
> pure synproxy can be used on firewall to protect the internal servers=
,
> which don't support neither syncookies and synproxy, from the attack
> of SYN-flood.
>=20

protecting servers using conntracking ?

Thats seems very dangerous to me.

> synproxy with defered connection relay acts as a layer 7 proxy, but
> works in kernel space totally, unlike tcp splice tech., which needs
> the applications in user space parse the requests, and establish the
> connections.
>=20

In the example given, only non persistent connections are handled...

These days, browsers and servers dont establish one socket per http
request...



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
