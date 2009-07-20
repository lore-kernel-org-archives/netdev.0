From: Noah Watkins <jayhawk@soe.ucsc.edu>
Subject: Re: regression: wireless authentication
Date: Mon, 20 Jul 2009 09:19:00 -0700 (PDT)
Message-ID: <1198385022.260301248106740802.JavaMail.root@mail-01.cse.ucsc.edu>
References: <1279186756.260191248106587108.JavaMail.root@mail-01.cse.ucsc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1279186756.260191248106587108.JavaMail.root@mail-01.cse.ucsc.edu>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The latest version I've tried that works fine is Linus' 2.6.31-rc3
with the latest commit being:

commit 35b5c55fee08e6e4001ba98060a2d0b82f70b5f4
Merge: e9e961c... b2dde6a...
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Wed Jul 15 10:29:09 2009 -0700

I encountered the problem I described when I booted:

2.6.31-rc3-next-20090716

-n

----- Original Message -----
=46rom: "John W. Linville" <linville@tuxdriver.com>
To: "Stephen Rothwell" <sfr@canb.auug.org.au>
Cc: "Noah Watkins" <jayhawk@soe.ucsc.edu>, linux-next@vger.kernel.org, =
"LKML" <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org, "David S=
=2E Miller" <davem@davemloft.net>
Sent: Monday, July 20, 2009 7:59:34 AM GMT -08:00 US/Canada Pacific
Subject: Re: regression: wireless authentication

On Fri, Jul 17, 2009 at 02:10:47PM +1000, Stephen Rothwell wrote:
> Hi Noah,
>=20
> Lets cc some people who may be able to help ...
>=20
> On Thu, 16 Jul 2009 20:57:06 -0700 Noah Watkins <jayhawk@soe.ucsc.edu=
> wrote:
> >
> > With 2.6.31-rc3-next-20090716 all wireless access points are detect=
ed, but
> > authentication fails. I haven't verified on an access point w/o WPA=
=2E
> >=20
> > 2.6.31-rc3 functions fine. I haven't been able to complete a bisect=
 yet.
> >=20
> > 05:01.0 Network controller: Atheros Communications Inc. AR5008 Wire=
less Network
> > Adapter (rev 01)

Odd...have you (i.e. Noah) been using -next trees all along?  What was
the last previous one that worked?  I didn't push anything out for
-next to pick-up all last week...

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
			=C2=A1Viva Honduras Libre!
