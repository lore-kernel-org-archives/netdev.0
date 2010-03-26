From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: behavior of recvmmsg() on blocking sockets
Date: Fri, 26 Mar 2010 15:20:10 +0100
Message-ID: <1269613210.2839.75.camel@edumazet-laptop>
References: <84621a61003241128x3afbcea1w387aeaa68c887320@mail.gmail.com>
	 <g76h4xrt5j1pw2kk3tUYAxe124vaj_firegpg@mail.gmail.com>
	 <84621a61003241635h65687366t6b28148281d529c9@mail.gmail.com>
	 <a36005b51003260500v6d8b7a5av1bbba848cc8998a4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brandon Black <blblack@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ulrich Drepper <drepper@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a36005b51003260500v6d8b7a5av1bbba848cc8998a4@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 26 mars 2010 =C3=A0 05:00 -0700, Ulrich Drepper a =C3=A9cri=
t :
> On Wed, Mar 24, 2010 at 16:35, Brandon Black <blblack@gmail.com> wrot=
e:
> > +                /* MSG_WAITFORONE turns on MSG_DONTWAIT after one =
packet */
> > +               if (!datagrams++ && flags & MSG_WAITFORONE)
> > +                       flags |=3D MSG_DONTWAIT;
>=20
> There should be an extra pair of parenthesis around the & operands bu=
t
> aside from that I could imagine this to work.
>=20
> Would be nice if the netdev folks would respond.


It seems fine, Brandon please submit a formal patch.

Thanks
