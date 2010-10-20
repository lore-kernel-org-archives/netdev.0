From: Ville =?iso-8859-1?Q?Syrj=E4l=E4?= <syrjala@sci.fi>
Subject: Re: [Ksummit-2010-discuss] [v2] Remaining BKL users, what to do
Date: Wed, 20 Oct 2010 19:14:55 +0300
Message-ID: <20101020161455.GC24313@sci.fi>
References: <201009161632.59210.arnd@arndb.de>
 <AANLkTi=oAeuz8ZxcOMpf=3MVY=WMt0BwHiGCUxO7OAEV@mail.gmail.com>
 <201010190926.54635.arnd@arndb.de>
 <201010191526.01887.arnd@arndb.de>
 <AANLkTinw=Wzh2Ucj6zKSoqC8J3Yq9xDr3mKMUB7K6Yyo@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Bergmann <arnd@arndb.de>, Jan Kara <jack@suse.cz>,
	Greg KH <greg@kroah.com>, Anders Larsen <al@alarsen.net>,
	dri-devel@lists.freedesktop.org,
	ksummit-2010-discuss@lists.linux-foundation.org,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	codalist@telemann.coda.cs.cmu.edu,
	Theodore Kilgore <kilgota@banach.math.auburn.edu>,
	Bryan Schumaker <bjschuma@netapp.com>,
	Christoph Hellwig <hch@infradead.org>,
	Petr Vandrovec <vandrove@vc.cvut.cz>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	linux-media@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>,
	Evgeniy Dushistov <dushistov@mail.ru>,
	Steven Rostedt <rostedt@goodmis.org>, autofs@linux.kernel.org,
	Jan Harkes <jaharkes@cs.cmu.edu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Andrew Hendry <andrew.hendry@gmail.com>
To: Dave Airlie <airlied@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTinw=Wzh2Ucj6zKSoqC8J3Yq9xDr3mKMUB7K6Yyo@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 20, 2010 at 06:50:58AM +1000, Dave Airlie wrote:
> On Tue, Oct 19, 2010 at 11:26 PM, Arnd Bergmann <arnd@arndb.de> wrote=
:
> > On Tuesday 19 October 2010, Arnd Bergmann wrote:
> >> On Tuesday 19 October 2010 06:52:32 Dave Airlie wrote:
> >> > > I might be able to find some hardware still lying around here =
that uses an
> >> > > i810. Not sure unless I go hunting it. But I get the impressio=
n that if
> >> > > the kernel is a single-CPU kernel there is not any problem any=
way? Don't
> >> > > distros offer a non-smp kernel as an installation option in ca=
se the user
> >> > > needs it? So in reality how big a problem is this?
> >> >
> >> > Not anymore, which is my old point of making a fuss. Nowadays in=
 the
> >> > modern distro world, we supply a single kernel that can at runti=
me
> >> > decide if its running on SMP or UP and rewrite the text section
> >> > appropriately with locks etc. Its like magic, and something like
> >> > marking drivers as BROKEN_ON_SMP at compile time is really wrong=
 when
> >> > what you want now is a runtime warning if someone tries to hotpl=
ug a
> >> > CPU with a known iffy driver loaded or if someone tries to load =
the
> >> > driver when we are already in SMP mode.
> >>
> >> We could make the driver run-time non-SMP by adding
> >>
> >> =A0 =A0 =A0 if (num_present_cpus() > 1) {
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("i810 no longer supports SMP\n"=
);
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> >> =A0 =A0 =A0 }
> >>
> >> to the init function. That would cover the vast majority of the
> >> users of i810 hardware, I guess.
> >
> > Some research showed that Intel never support i810/i815 SMP setups,
> > but there was indeed one company (http://www.acorpusa.com at the ti=
me,
> > now owned by a domain squatter) that made i815E based dual Pentium-=
III
> > boards like this one: http://cgi.ebay.com/280319795096
>=20
> Also that board has no on-board GPU enabled i815EP (P means no on-boa=
rd GPU).

A quick search seems to indicate that an i815E variant also existed.

--=20
Ville Syrj=E4l=E4
syrjala@sci.fi
http://www.sci.fi/~syrjala/
--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
