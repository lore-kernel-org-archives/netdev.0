From: Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
Subject: Re: i386 allmodconfig, current mainline
Date: Fri, 13 Aug 2010 09:23:09 -0700
Message-ID: <20100813092309.fd54fc28.rdunlap@xenotime.net>
References: <20100809164346.6e30cf8c.akpm@linux-foundation.org>
	<20100810101521.0dcd4393.sfr@canb.auug.org.au>
	<AANLkTimtZ7H=rT68V6UGC2GBky8z9VJ5m6-pwFHfm7yw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>,
	Kevin Curtis <kevin.curtis-AP8L3A0T/wQqdlJmJB21zg@public.gmane.org>,
	Phillip Lougher <phillip-cnXvMjJKhjYG2Il/BtU0GPXRex20P6io@public.gmane.org>,
	Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Chien Tung <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Samuel Ortiz <samuel.ortiz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTimtZ7H=rT68V6UGC2GBky8z9VJ5m6-pwFHfm7yw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 10 Aug 2010 18:53:20 +0200 Geert Uytterhoeven wrote:

> On Tue, Aug 10, 2010 at 02:15, Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org=
> wrote:
> > On Mon, 9 Aug 2010 16:43:46 -0700 Andrew Morton <akpm@linux-foundat=
ion.org> wrote:
> >>
> >> Guys. =A0What's goin' on out there?
> >
> > I guess we are all so up to date that noone does 32 bit builds any
> > more ... =A0Also noone is bothering to look at the build logs:
> >
> > linus tree: http://kisskb.ellerman.id.au/kisskb/branch/3/
> > linux-next: http://kisskb.ellerman.id.au/kisskb/branch/9/
>=20
> Yeah, we have build failures migrating from -next to -linus :-(
>=20
> BTW, still no one has commented on http://lkml.org/lkml/2010/7/13/378=
?

OK.

The diff (regression) script output looks useful to me.
The log summary is still quite (too) verbose, or maybe that's partly du=
e
to the number of warnings & errors.  :(


Maybe someone could look at http://www.xenotime.net/linux/scripts/build=
summary.pl also.

Here is today's linux-next *i386* build summary, short mode (totals onl=
y):

> buildsummary.pl -t build*.out | more
build-r5372.out: totals: error/warning files: 27, errors: 3, warnings: =
44, Section mismatches: 36
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5373.out: totals: error/warning files: 10, errors: 3, warnings: =
14, Section mismatches: 36
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5374.out: totals: error/warning files: 29, errors: 0, warnings: =
45, Section mismatches: 38
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5375.out: totals: error/warning files: 18, errors: 3, warnings: =
36, Section mismatches: 38
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5377.out: totals: error/warning files: 21, errors: 0, warnings: =
43, Section mismatches: 67
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5380.out: totals: error/warning files: 16, errors: 4, warnings: =
22, Section mismatches: 81
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5381.out: totals: error/warning files: 17, errors: 3, warnings: =
75, Section mismatches: 88
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5383.out: totals: error/warning files: 11, errors: 0, warnings: =
32, Section mismatches: 130
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5384.out: totals: error/warning files: 23, errors: 3, warnings: =
47, Section mismatches: 150
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5385.out: totals: error/warning files: 6, errors: 12, warnings: =
9, Section mismatches: 160
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5386.out: totals: error/warning files: 10, errors: 1, warnings: =
53, Section mismatches: 163
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5387.out: totals: error/warning files: 18, errors: 0, warnings: =
45, Section mismatches: 164
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5388.out: totals: error/warning files: 7, errors: 1, warnings: 8=
, Section mismatches: 164
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5389.out: totals: error/warning files: 43, errors: 0, warnings: =
80, Section mismatches: 167
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5390.out: totals: error/warning files: 12, errors: 0, warnings: =
18, Section mismatches: 167
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5391.out: totals: error/warning files: 46, errors: 0, warnings: =
77, Section mismatches: 170
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5392.out: totals: error/warning files: 15, errors: 12, warnings:=
 31, Section mismatches: 184
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5393.out: totals: error/warning files: 15, errors: 0, warnings: =
23, Section mismatches: 187
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5394.out: totals: error/warning files: 76, errors: 0, warnings: =
141, Section mismatches: 190
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5395.out: totals: error/warning files: 11, errors: 0, warnings: =
18, Section mismatches: 192
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
build-r5396.out: totals: error/warning files: 22, errors: 0, warnings: =
28, Section mismatches: 193
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your cod=
e ***
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
