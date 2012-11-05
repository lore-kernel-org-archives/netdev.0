From: Lee Jones <lee.jones@linaro.org>
Subject: Re: [PATCH 8/9] isdn: Remove unused variable causing a compile build
 warning
Date: Mon, 5 Nov 2012 09:44:19 +0100
Message-ID: <20121105084419.GC2699@gmail.com>
References: <20121103224832.GA24262@gmail.com>
 <1352024091.1434.17.camel@x61.thuisdomein>
 <20121104105332.GC27124@gmail.com>
 <20121104.123013.700345271120279281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pebolle@tiscali.nl, linux-kernel@vger.kernel.org,
	isdn@linux-pingi.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121104.123013.700345271120279281.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 04 Nov 2012, David Miller wrote:

> From: Lee Jones <lee.jones@linaro.org>
> Date: Sun, 4 Nov 2012 11:53:32 +0100
>=20
> > On Sun, 04 Nov 2012, Paul Bolle wrote:
> >=20
> >> On Sat, 2012-11-03 at 23:48 +0100, Lee Jones wrote:
> >> > On Sat, 03 Nov 2012, Paul Bolle wrote:
> >> > > On Sat, 2012-11-03 at 23:02 +0100, Lee Jones wrote:
> >> > > > This patch fixes:
> >> > > > drivers/isdn/i4l/isdn_common.c: In function =E2=80=98isdn_io=
ctl=E2=80=99:
> >> > > > drivers/isdn/i4l/isdn_common.c:1278:8: warning: unused varia=
ble =E2=80=98s=E2=80=99 [-Wunused-variable]
> >> > >=20
> >> > > Did you have CONFIG_NETDEVICES not set in this build?
> >> >=20
> >> > Ah yes, I see it. The function went down further than I thought
> >> > it did. So the real fix is to ensure 's' is defined inside of
> >> > some ifdef CONFIG_NETDEVICES guards.=20
> >>=20
> >> What puzzles me is that we only find these "#ifdef CONFIG_NETDEVIC=
ES"
> >> guards in this file and not in isdn_net.c, were all the ioctl comm=
ands
> >> guarded that way seem to be calling into. On first glance that doe=
sn't
> >> make much sense.
> >>=20
> >> (Actually the idea of having ISDN without NETDEVICES is a bit puzz=
ling
> >> too. But there are too many parts of the isdn subsystem that I'm
> >> unfamiliar with to say whether that can make sense.)
> >=20
> > I'm in the same position as you Paul. I just noticed the warning so
> > fixed it following the current way of doing things. Any, more
> > substantial changes requiring greater knowledge of the subsystem
> > would have to be done by someone else.
>=20
> I think the most appropriate thing to do is make CONFIG_ISDN depend
> upon CONFIG_NETDEVICES in the Kconfig file.

=2E.. and then remove the CONFIG_NETDEVICES guards in isdn_common.c?

If that's suitable more suitable I can do that instead?

Just need a yay or nay and I'll make it happen.

--=20
Lee Jones
Linaro ST-Ericsson Landing Team Lead
Linaro.org =E2=94=82 Open source software for ARM SoCs
=46ollow Linaro: Facebook | Twitter | Blog
