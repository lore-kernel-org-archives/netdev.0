From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Mon, 10 Sep 2007 18:02:17 +0100
Message-ID: <20070910180217.7cc9878b@laptopd505.fenrus.org>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com>
	<200709101156.30010.vda.linux@googlemail.com>
	<20070910155156.2c1453fc@laptopd505.fenrus.org>
	<200709101538.25132.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Nick Piggin <piggin@cyberone.com.au>,
	Satyam Sharma <satyam@infradead.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:42964 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964836AbXIJQDp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 12:03:45 -0400
In-Reply-To: <200709101538.25132.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 10 Sep 2007 15:38:23 +0100
Denys Vlasenko <vda.linux@googlemail.com> wrote:

> On Monday 10 September 2007 15:51, Arjan van de Ven wrote:
> > On Mon, 10 Sep 2007 11:56:29 +0100
> > Denys Vlasenko <vda.linux@googlemail.com> wrote:
> >=20
> > >=20
> > > Well, if you insist on having it again:
> > >=20
> > > Waiting for atomic value to be zero:
> > >=20
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0while (atomic_rea=
d(&x))
> > > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0continue;
> > >=20
> >=20
> > and this I would say is buggy code all the way.
> >
> > Not from a pure C level semantics, but from a "busy waiting is
> > buggy" semantics level and a "I'm inventing my own locking"
> > semantics level.
>=20
> After inspecting arch/*, I cannot agree with you.

the arch/ people obviously are allowed to do their own locking stuff...
BECAUSE THEY HAVE TO IMPLEMENT THAT!


the arch maintainers know EXACTLY how their hw behaves (well, we hope)
so they tend to be the exception to many rules in the kernel....
