From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Tue, 02 Feb 2010 06:04:50 -0500
Message-ID: <1265108690.2861.118.camel@tonnant>
References: <1264813832.2793.446.camel@tonnant>
	 <1264816634.2793.505.camel@tonnant> <1264816777.2793.510.camel@tonnant>
	 <1264834704.2919.3.camel@edumazet-laptop>
	 <1265016745.7499.144.camel@tonnant>
	 <b6fcc0a1002010136k7e78a998p31a9e7464c2e8d44@mail.gmail.com>
	 <1265019160.2848.14.camel@edumazet-laptop>
	 <b6fcc0a1002010225u4e74f9f0q633d73038234dc37@mail.gmail.com>
	 <1265023437.2848.30.camel@edumazet-laptop>
	 <1265035970.2848.50.camel@edumazet-laptop>
	 <b6fcc0a1002010658j4f52a9b8kf10e4bb07a2f1075@mail.gmail.com>
	 <1265036548.2848.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dallas.jonmasters.org ([72.29.103.172]:60677 "EHLO
	dallas.jonmasters.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753827Ab0BBLFK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 06:05:10 -0500
In-Reply-To: <1265036548.2848.55.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-02-01 at 16:02 +0100, Eric Dumazet wrote:
> Le lundi 01 f=C3=A9vrier 2010 =C3=A0 16:58 +0200, Alexey Dobriyan a =C3=
=A9crit :
> > On Mon, Feb 1, 2010 at 4:52 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> > > +       net->ct.nf_conntrack_cachep =3D kmem_cache_create("nf_con=
ntrack",
> > > +                                                       sizeof(st=
ruct nf_conn), 0,
> > > +                                                       SLAB_DEST=
ROY_BY_RCU, NULL);
> >=20
> > Duplicate slab name detected.
> >=20
>=20
> OK, need to build an unique name I guess... "nf_conntrack-%d", net->i=
d

I shoved in an kasprintf but of course there isn't a per-namespace "id"=
=2E
We probably should have one (or, a nice "name"), but meanwhile I am
using the address of the net struct like "nf_ct-%p".

Jon.


