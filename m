From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] gro: Is it ok to share a single napi from several devs ?
Date: Sun, 29 Aug 2010 20:39:22 +0200
Message-ID: <1283107162.2297.32.camel@edumazet-laptop>
References: <20100828101424.69c4c782@s6510>
	 <20100828.144130.189711704.davem@davemloft.net>
	 <20100829095951.GA3153@del.dom.local>
	 <20100829.100653.70199372.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, shemminger@vyatta.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41783 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753943Ab0H2Sj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Aug 2010 14:39:27 -0400
Received: by wyb35 with SMTP id 35so5936350wyb.19
        for <netdev@vger.kernel.org>; Sun, 29 Aug 2010 11:39:26 -0700 (PDT)
In-Reply-To: <20100829.100653.70199372.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 29 ao=C3=BBt 2010 =C3=A0 10:06 -0700, David Miller a =C3=A9=
crit :
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sun, 29 Aug 2010 11:59:51 +0200
>=20
> > Actually, when GRO compares napi->dev to skb->dev?
>=20
> Hmmm, I thought the code made a skb->dev comparison with the
> existing SKBs in the list when checking for same-flow matches.
>=20
> It doesn't, probably based upon the assumption that a NAPI
> instance maps to a unique device, the very topic we're
> discussing right now :-/
>=20
>=20

It does the check, Stephen added it in the commit I mentioned to start
this thread.

With net-next-2.6 this now reads :


