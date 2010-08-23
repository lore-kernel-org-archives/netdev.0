From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BISECTED][2.6.35 regression] iptables busted on Mac G5
Date: Mon, 23 Aug 2010 14:34:22 +0200
Message-ID: <1282566862.2486.29.camel@edumazet-laptop>
References: <19546.53659.970308.750410@pilspetsen.it.uu.se>
	 <19570.25954.196694.563887@pilspetsen.it.uu.se>
	 <20100823121644.GH1727@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mikael Pettersson <mikpe@it.uu.se>, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Jan Engelhardt <jengelh@medozas.de>,
	netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100823121644.GH1727@Chamillionaire.breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 23 ao=C3=BBt 2010 =C3=A0 14:16 +0200, Florian Westphal a =C3=A9=
crit :
> Mikael Pettersson <mikpe@it.uu.se> wrote:
> >  > I'll try to narrow it down further next week when I'm at the
> >  > machine's location again.  Meanwhile I would be grateful if
> >  > anyone has any ideas about what the issue might be.  I'll add
> >  > that a Mac G4 (ppc32) with similar kernel configuration and
> >  > user-space works fine with 2.6.35 and iptables.
> >=20
> > The bug is still present in 2.6.36-rc2.
>=20
> sigh.
> Do you run 64 bit kernel with 32bit userland?
> If so, yes, thats broken since 2.6.35. I submitted a fix
> (http://marc.info/?l=3Dnetfilter-devel&m=3D128116762801769&w=3D2),
> but it was not yet applied.
>=20
> Will resend it later today.

CC netdev

Please send this patch to netdev@vger.kernel.org and David S. Miller,
because it seems Patrick is on vacation or something.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
