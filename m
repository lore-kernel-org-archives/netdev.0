From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic when using netns+bridges+tc(netem)
Date: Thu, 06 May 2010 21:15:03 +0200
Message-ID: <1273173303.2222.11.camel@edumazet-laptop>
References: <o2wb9800b71005051801uc575c6abp5bad3bd50d54ef96@mail.gmail.com>
	 <1273128002.2304.4.camel@edumazet-laptop>
	 <1273128429.2304.5.camel@edumazet-laptop>
	 <1273129187.2304.14.camel@edumazet-laptop>
	 <h2vb9800b71005060423rc0f4bd3g4109e90f798d5157@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Bergmann <arnd@arndb.de>, netdev <netdev@vger.kernel.org>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Mart=EDn?= Ferrari <martin.ferrari@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:64221 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754263Ab0EFTPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 15:15:09 -0400
Received: by bwz19 with SMTP id 19so184407bwz.21
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 12:15:06 -0700 (PDT)
In-Reply-To: <h2vb9800b71005060423rc0f4bd3g4109e90f798d5157@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 mai 2010 =C3=A0 13:23 +0200, Mart=C3=ADn Ferrari a =C3=A9cr=
it :
> Eric,
>=20
> On Thu, May 6, 2010 at 08:59, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> >> > Could you please try following patch ?
> > David, this is a stable candidate, once tested and acked, thanks !
> >
> > [PATCH] veth: Dont kfree_skb() after dev_forward_skb()
>=20
> I have been running a bunch of benchmarks and it didn't cause any
> trouble. Seems the fix is good
>=20
> Thanks a lot!!
>=20

Thanks for testing and report !


