From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] r8169: revert "add byte queue limit support".
Date: Fri, 27 Jul 2012 07:27:48 +0200
Message-ID: <1343366868.2626.12188.camel@edumazet-glaptop>
References: <20120723205555.GA4392@electric-eye.fr.zoreil.com>
	 <1343106407.2626.11038.camel@edumazet-glaptop>
	 <20120724053811.GA12053@electric-eye.fr.zoreil.com>
	 <201207270536.50292.s.L-H@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	David Miller <davem@davemloft.net>, hayeswang@realtek.com,
	netdev@vger.kernel.org,
	Alex =?ISO-8859-1?Q?Villac=EDs?= Lasso
	<a_villacis@palosanto.com>, Josh Boyer <jwboyer@redhat.com>,
	Tom Herbert <therbert@google.com>
To: Stefan Lippers-Hollmann <s.L-H@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:62629 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930Ab2G0F1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 01:27:54 -0400
Received: by wgbdr13 with SMTP id dr13so2454717wgb.1
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 22:27:53 -0700 (PDT)
In-Reply-To: <201207270536.50292.s.L-H@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-07-27 at 05:36 +0200, Stefan Lippers-Hollmann wrote:
> Hi
>=20
> On Tuesday 24 July 2012, Francois Romieu wrote:
> > Eric Dumazet <eric.dumazet@gmail.com> :
> > > On Mon, 2012-07-23 at 22:55 +0200, Francois Romieu wrote:
> > > > This reverts commit 036dafa28da1e2565a8529de2ae663c37b7a0060.
> > [...]
> > > bisection is not always the right way to qualify a problem.
> >=20
> > I know. At some point I switch from "I could search more" to "users=
 situation
> > will improve in a definite timeframe".
> >=20
> > > BQL in itself had some fixes coming _after_ commit 036dafa28da1e2=
565
> >=20
> > Thanks.
> >=20
> > They are in stable as of 3.4.5:
> [=E2=80=A6]
> > I have obviously not directed users at them and I do not see any
> > of the victims using a non -stable / -vendor or recent enough
> > kernel to test this patch since the issue has been reported.
> >=20
> > They are both worth testing.
> [=E2=80=A6]
>=20
> 3.4.x up to and including 3.4.4 exposed the problem on these cards[1]=
:
>=20
> r8169 0000:04:00.0: eth0: RTL8168d/8111d at 0xffffc90000c72000, 00:24=
:1d:72:7c:75, XID 081000c0 IRQ 44
> r8169 0000:05:00.0: eth1: RTL8168d/8111d at 0xffffc90000c70000, 00:24=
:1d:72:7c:77, XID 081000c0 IRQ 45
>=20
> while it is stable with "add byte queue limit support" reverted; 3.4.=
5+
> was only tested with 036dafa28da1e2565a8529de2ae663c37b7a0060 reverte=
d.
>=20
> Now testing plain 3.5.0, which still includes it, has been reliable f=
or
> almost 3 days - while the issue usually triggered within one hour (3=20
> hours at most) in 3.4.[0-4]. It might be a little too early to give a
> definitive answer, but so far r8169/ 3.5.0 looks positive.
>=20
> Regards
> 	Stefan Lippers-Hollmann
>=20
> [1]	Message-Id: <201206290131.49150.s.L-H@gmx.de>
> 	http://lkml.kernel.org/r/<201206290131.49150.s.L-H@gmx.de>

Thats real good news, thanks !
