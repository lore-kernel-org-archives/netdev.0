From: Joe Perches <joe@perches.com>
Subject: Re: [RFC net-next 0/2] Create ancient subdirectories for old
 hardware
Date: Sat, 19 Mar 2016 08:36:32 -0700
Message-ID: <1458401792.26915.65.camel@perches.com>
References: <cover.1458347329.git.joe@perches.com>
	 <20160318.221153.997255526626920777.davem@davemloft.net>
	 <1458354482.26915.35.camel@perches.com>
	 <20160318.231626.670272515350508280.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160318.231626.670272515350508280.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-03-18 at 23:16 -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>=A0Date: Fri, 18 Mar 2016 19:28:02=
 -0700
> > On Fri, 2016-03-18 at 22:11 -0400, David Miller wrote:
> >> From: Joe Perches <joe@perches.com> Date: Fri, 18 Mar 2016 17:33:2=
9 -0700
> >> > Maybe something like this:=A0
> >> > Old, rare, and unsupported hardware should be exposed as ancient=
=2E
> >> >=A0
> >> > The drivers for these ancient hardwares are generally untested w=
ith
> >> > current kernels.
> >>=A0
> >> Moving drivers has a long term maintainence cost.
> >>=A0
> >> If they've moved into drivers/net proper, we have to maintain
> >> them there forever.
> >=A0
> > I don't doubt that.

Actually I rather do kind of doubt that.

Look for instance at what's proposed now for drivers/isdn
which realistically, could have been in drivers/net.

Also, various bits of hardware support have already been
dropped from drivers/net. =A0The 3c503, ni52 and others=A0
come to mind. Token Ring support too.

Today, I expect there aren't many Packet Engines devices,
either hamachi or yellowfin, still being used, especially
with kernel versions > 4.

> > All files are still in drivers/net, just possibly in
> > separate subdirectories for easier visibility to
> > determine if changes like what were proposed for cxgb
> > should actually be done or not.
>=20
> You don't understand my concern, backporting patches to -stable
> releases is more painful if you move the driver anywhere other
> than where it has been for years.
>=20
> I'm not entertaining this idea, sorry Joe.

I do understand your concern. =A0Backporting patches to obsolete
hardware shouldn't much be necessary as obsolete hardware,
as you wrote yourself, simply doens't get much testing.

Archaic stuff should eventually get sifted out altogether.

Marking drivers as archaic at least allows people that use
use the older devices to object and maybe actually step up
to maintain them too.
