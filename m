From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC net-next 2/2] tcp: Add Redundant Data Bundling (RDB)
Date: Mon, 2 Nov 2015 09:18:20 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBC86C4@AcuExch.aculab.com>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
 <C1235108-1DC2-408E-8CAC-65DBE628AB78@simula.no>
 <CAK6E8=fyY_kQ4ZpyC+q3fH-CFvwDt_=ro2Y7qB9bxgMCpkcC3g@mail.gmail.com>
 <3710572.sJUWpao1xp@bro-compal>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andreas Petlund <apetlund@simula.no>,
	Neal Cardwell <ncardwell@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	"Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Jonathan Corbet <corbet@lwn.net>,
	Eric Dumazet <edumazet@google.com>,
	"Tom Herbert" <tom@herbertland.com>,
	Paolo Abeni <pabeni@redhat.com>, Erik Kline <ek@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Daniel Lee <Longinus00@gmail.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	"Daniel Borkmann" <daniel@iogearbox.net>,
	Willem de Bruijn <willemb@google.com>,
	=?Windows-1252?Q?Linus_L=FCssing?= <linus.luessing@c0d3.blue>,
	"linux-
To: "'bro.devel+kernel@gmail.com'" <bro.devel+kernel@gmail.com>,
	Yuchung Cheng <ycheng@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3710572.sJUWpao1xp@bro-compal>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Bendik R=F8nning Opstad
> Sent: 29 October 2015 22:54
=2E..
> > > > The semantics of the tp->nonagle bits are already a bit complex=
=2E My
> > > > sense is that having a setsockopt of TCP_RDB transparently modi=
fy the
> > > > nagle behavior is going to add more extra complexity and unanti=
cipated
> > > > behavior than is warranted given the slight possible gain in
> > > > convenience to the app writer. What about a model where the
> > > > application user just needs to remember to call
> > > > setsockopt(TCP_NODELAY) if they want the TCP_RDB behavior to be
> > > > sensible? I see your nice tests at
> > > >
> > > >   https://github.com/bendikro/packetdrill/commit/9916b6c53e33dd=
04329d29b
> > > >   7d8baf703b2c2ac1b> >
> > > > are already doing that. And my sense is that likewise most
> > > > well-engineered "thin stream" apps will already be using
> > > > setsockopt(TCP_NODELAY). Is that workable?
>=20
> This is definitely workable. I agree that it may not be an ideal solu=
tion to
> have TCP_RDB disable Nagle, however, it would be useful with a way to=
 easily
> enable RDB and disable Nagle.

If enabling RDB disables Nagle, then what happens when you turn RDB bac=
k off?

	David
