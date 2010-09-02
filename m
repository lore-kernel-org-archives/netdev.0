From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] drivers/net : avoid some skb->ip_summed
 initializations
Date: Thu, 02 Sep 2010 21:13:00 +0200
Message-ID: <1283454780.3699.22.camel@edumazet-laptop>
References: <1283444746.2454.1132.camel@edumazet-laptop>
	 <20100902.094135.112603353.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39424 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656Ab0IBTNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 15:13:05 -0400
Received: by wyb35 with SMTP id 35so53384wyb.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 12:13:04 -0700 (PDT)
In-Reply-To: <20100902.094135.112603353.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 septembre 2010 =C3=A0 09:41 -0700, David Miller a =C3=A9cri=
t :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 02 Sep 2010 18:25:46 +0200
>=20
> > fresh skbs have ip_summed set to CHECKSUM_NONE (0)
> >=20
> > We can avoid setting again skb->ip_summed to CHECKSUM_NONE in drive=
rs.
> >=20
> > Introduce skb_CHECKSUM_NONE_assert() helper so that we keep this
> > assertion documented in driver sources.
> >=20
> > Change most occurrences of :
> >=20
> > skb->ip_summed =3D CHECKSUM_NONE;
> >=20
> > by :
> >=20
> > skb_CHECKSUM_NONE_assert(skb);
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Please, no capital letters in C function names.
>=20
> I'll apply this with that fixed up.
>=20

Well, I wanted to keep the CHECKSUM_NONE "as is" to ease grep games.

Choices are :

1) put it in lower case : skb_checksum_none_assert()
2) Use a macro instead.
3) Other idea ?

(not sure if you already applied the patch or if you want a v2 from me)

Thanks !



