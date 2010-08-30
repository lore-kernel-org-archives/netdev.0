From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] netpoll: Is it ok to share a single napi from several
 devs ?
Date: Mon, 30 Aug 2010 22:19:09 +0200
Message-ID: <1283199549.2405.9.camel@edumazet-laptop>
References: <1283107162.2297.32.camel@edumazet-laptop>
	 <20100830064231.GA7060@ff.dom.local> <20100830085721.54c8c31b@nehalam>
	 <20100830.095012.233695092.davem@davemloft.net>
	 <20100830183620.GA3079@del.dom.local>
	 <1283198356.2405.8.camel@edumazet-laptop> <20100830131246.25b16e8e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46249 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753902Ab0H3UTO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 16:19:14 -0400
Received: by wyb35 with SMTP id 35so7012188wyb.19
        for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 13:19:13 -0700 (PDT)
In-Reply-To: <20100830131246.25b16e8e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 30 ao=C3=BBt 2010 =C3=A0 13:12 -0700, Stephen Hemminger a =C3=A9=
crit :
> On Mon, 30 Aug 2010 21:59:16 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > So everybody jumped on GRO, while my concern was more the napi->dev
> > thing.
> >=20
> > I pointed to gro because the commit was about gro, but gro was fine
> > IMHO.
> >=20
> > Are we sure netpoll is ok ?
>=20
> Netpoll is dependent on napi->netdev but does not cause problems.
> The sky2 driver doesn't expose netpoll on second port.
> The second port has different net_device_ops without netpoll.
>=20
>=20

Ah, great, thanks for clarification.


