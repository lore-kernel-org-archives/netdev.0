From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Thu, 22 Dec 2011 08:57:31 +0100
Message-ID: <1324540651.2621.44.camel@edumazet-laptop>
References: <4EF1EC28.90008@monstr.eu>
		<1324483144.2301.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
		<1324487504.2301.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111221.155520.1406613141134089105.davem@davemloft.net>
	 <4EF2E102.7030008@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, john.williams@petalogix.com,
	netdev@vger.kernel.org
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:53139 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab1LVH5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 02:57:36 -0500
Received: by wibhm6 with SMTP id hm6so2358304wib.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 23:57:35 -0800 (PST)
In-Reply-To: <4EF2E102.7030008@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 22 d=C3=A9cembre 2011 =C3=A0 08:49 +0100, Michal Simek a =C3=A9=
crit :
> David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Wed, 21 Dec 2011 18:11:44 +0100
> >=20
> >> [PATCH net-next] net: relax rcvbuf limits
> >>
> >> skb->truesize might be big even for a small packet.
> >>
> >> Its even bigger after commit 87fb4b7b533 (net: more accurate skb
> >> truesize) and big MTU.
> >>
> >> We should allow queueing at least one packet per receiver, even wi=
th a
> >> low RCVBUF setting.
> >>
> >> Reported-by: Michal Simek <monstr@monstr.eu>
> >> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >=20
> > Applied to net-next, although I was tempted to put it into net.
> >=20
> > We may end up backporting this into -stable at some point, we'll
> > see.
>=20
> Yes, it works. Thanks Eric.
>=20
> I hope that this patch will be in v3.2.
>=20

Thanks for testing !

I overlooked fact that commit 87fb4b7b533 was already in 3.2, so yes, w=
e
probably can push this to 3.2

(By the way, busybox ping probably doesnt work on 3.1 kernel with a
MTU=3D9000 non copybreak driver, so its not a clear 3.2 regression)
