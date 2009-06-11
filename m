From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver
	configuration.
Date: Thu, 11 Jun 2009 19:29:27 +0100
Message-ID: <1244744967.2785.61.camel@achroite>
References: <20090610173243.17262.91308.stgit@srv002.fuzzey.net>
	 <1244685768.4616.22.camel@deadeye> <4A30A884.9000508@gmail.com>
	 <1244732090.2785.12.camel@achroite>
	 <alpine.LFD.2.00.0906111159080.31536@xanadu.home>
	 <1244739166.2785.52.camel@achroite>
	 <alpine.LFD.2.00.0906111333100.31536@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mfuzzey@gmail.com, netdev@vger.kernel.org
To: Nicolas Pitre <nico@cam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:56747 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756569AbZFKS3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 14:29:30 -0400
In-Reply-To: <alpine.LFD.2.00.0906111333100.31536@xanadu.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-06-11 at 13:44 -0400, Nicolas Pitre wrote:
> On Thu, 11 Jun 2009, Ben Hutchings wrote:
>=20
> > On Thu, 2009-06-11 at 12:22 -0400, Nicolas Pitre wrote:
> > > On Thu, 11 Jun 2009, Ben Hutchings wrote:
> > >=20
> > > > On Thu, 2009-06-11 at 08:47 +0200, Martin Fuzzey wrote:
> > > > > Ben Hutchings wrote:
> > > > > > Who needs this feature?  Why not use ethtool in an initramf=
s?
> > > > > >
> > > > > >  =20
> > > > > > Forcing speed and duplex is occasionally needed to work aro=
und a link
> > > > > > partner that doesn't implement autonegotiation correctly.  =
I don't see
> > > > > > that it should ever be needed in platform configuration.  I=
f the driver
> > > > > > doesn't detect the MAC/PHY capabilities correctly then the =
driver should
> > > > > > be fixed.  Overriding the settings once will not prevent an=
 unsupported
> > > > > > mode being selected later.
> > > > > >
> > > > > >  =20
> > > > > To summarize the recent points I made in the smc91x: forcing =
speed thread :
> > > > >=20
> > > > > 1) Setting up and maintaining an initramfs can increase the c=
omplexity
> > > > > for embedded systems - it's another image file to build, dist=
ribute,
> > > > > update to bootloader etc.
> > > >=20
> > > > This doesn't seem like a huge burden if you're net-booting.  An=
d if
> > > > you're not net-booting, it's not critical that you override the=
 link
> > > > mode immediately; you can do it in the regular init scripts.
> > >=20
> > > Sure... But for some embedded setup this is actually more trouble=
 and=20
> > > hassle than having a non-intrusive kernel based facility that can=
 set=20
> > > defaults for you.
> >=20
> > Doing it in an init script is even less intrusive!  But it seems th=
at
> > the ethtool API doesn't do what you need in this case, anyway.
>=20
> Stop thinking in terms of workstation setups please.

Maybe you should stop thinking that an embedded system has to do things
entirely differently?  Please note, I'm talking about an init script -
which you surely must have - not an initramfs, which I recognise is
optional and unnecessary for most embedded systems.

> [...]
> > It's an example of providing a generic solution, which is definitel=
y
> > more than a quick hack, but I don't see it as a "clean solution" fo=
r the
> > problem that certain link modes don't work on a particular board.  =
A
> > clean solution would disable those modes altogether in the driver.
>=20
> And now you are considering the addition of special restrictions for=20
> some special hardware directly into the driver as less intrusive than=
=20
> what is being proposed?  And now imagine what this would look like af=
ter=20
> 56 different embedded designs have added their own kirks into the=20
> driver.. because, yes, in the embedded world you do have much more th=
an=20
> 56 different designs sharing the same driver but each with their own=20
> flaws.
[...]

=EF=BB=BFI was thinking that you could add it to the platform data for =
such
devices, not that you would put board-specific quirks in the drivers.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

