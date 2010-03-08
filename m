From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP_COOKIE_TRANSACTIONS synack data
Date: Mon, 08 Mar 2010 17:01:10 +0100
Message-ID: <1268064070.6148.104.camel@edumazet-laptop>
References: <2BC93087D531FF4A98881820AFE8AE7B74C409E1C3@jklmail01.ixonos.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	William Allen Simpson <william.allen.simpson@gmail.com>
To: =?ISO-8859-1?Q?Penttil=E4?= Mika <mika.penttila@ixonos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:44938 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755360Ab0CHQBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 11:01:16 -0500
Received: by bwz1 with SMTP id 1so2934656bwz.21
        for <netdev@vger.kernel.org>; Mon, 08 Mar 2010 08:01:14 -0800 (PST)
In-Reply-To: <2BC93087D531FF4A98881820AFE8AE7B74C409E1C3@jklmail01.ixonos.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 08 mars 2010 =C3=A0 16:27 +0200, Penttil=C3=A4 Mika a =C3=A9cr=
it :
> The TCP_COOKIE_TRANSACTIONS synack data seems pretty unsafe atm.=20
> >From tcp_make_synack():
>=20
>=20
> 	u8 *buf =3D skb_put(skb, cvp->s_data_desired);
>=20
> 	/* copy data directly from the listening socket. */
>     	memcpy(buf, cvp->s_data_payload, cvp->s_data_desired);
>=20
>=20
> The skb here is allocated for MAX_TCP_HEADER + 15 and synack data cou=
ld be as long as TCP_MSS_DEFAULT, panic():ing at the skb_put().
>=20

Indeed, since start of december 2009.

Do you plan to provide a patch do you prefer someone else take care of
it ?

Thanks


