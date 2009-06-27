From: Maciej Rutecki <maciej.rutecki@gmail.com>
Subject: Re: [2.6.31-rc1] iwlagn (4965): no wireless due to RFKILL problem
Date: Sat, 27 Jun 2009 11:49:28 +0200
Message-ID: <8db1092f0906270249k58b3bd48yc4c93113641cc5ac@mail.gmail.com>
References: <200906261336.29318.elendil@planet.nl>
	 <8db1092f0906260459n308311faweb6d9733cdd1eb13@mail.gmail.com>
	 <200906261410.58808.elendil@planet.nl>
	 <1246048132.21314.75.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frans Pop <elendil@planet.nl>, linux-wireless@vger.kernel.org,
	Netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	Alan Jenkins <alan-jenkins@tuffmail.co.uk>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754060AbZF0Jti@vger.kernel.org>
In-Reply-To: <1246048132.21314.75.camel@johannes.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2009/6/26 Johannes Berg <johannes@sipsolutions.net>:

> Hmm, looks like there might be another polarity error, try this:
> - =C2=A0 =C2=A0 =C2=A0 int query =3D BIT(b + 8) | ((!!blocked) << b);
> + =C2=A0 =C2=A0 =C2=A0 int query =3D BIT(b + 8) | ((!blocked) << b);
>

This helps. hp-wmi works without any problems.

Tested-by Maciej Rutecki <maciej.rutecki@gmail.com>

Thanks
--=20
Maciej Rutecki
http://www.maciek.unixy.pl
