From: Volker Armin Hemmann <volker.armin.hemmann@tu-clausthal.de>
Subject: Re: [stable] build error with 2.6.27.6+reiser4+ehci-hub patch. ERROR: "mii_ethtool_gset" [drivers/net/r8169.ko] undefined!
Date: Fri, 14 Nov 2008 07:39:46 +0100
Message-ID: <200811140739.46888.volker.armin.hemmann@tu-clausthal.de>
References: <200811140045.20166.volker.armin.hemmann@tu-clausthal.de> <20081114012617.GG7331@solarflare.com> <20081114040732.GB17810@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	linux-kernel@vger.kernel.org, stable@kernel.org,
	netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hades.rz.tu-clausthal.de ([139.174.2.20]:63117 "EHLO
	hades.rz.tu-clausthal.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbYKNGjx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 01:39:53 -0500
In-Reply-To: <20081114040732.GB17810@kroah.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Freitag 14 November 2008, Greg KH wrote:
> On Fri, Nov 14, 2008 at 01:26:19AM +0000, Ben Hutchings wrote:
> > Greg KH wrote:
> > > On Fri, Nov 14, 2008 at 12:45:19AM +0100, Volker Armin Hemmann wr=
ote:
> > > > Hi,
> > > > with my old config from 2.6.27.5 (which has the same patches) I=
 get
> > > > this error:
> > > > make all modules_install install
> > > > <snip>
> > > >   OBJCOPY arch/x86/boot/setup.bin
> > > >   OBJCOPY arch/x86/boot/vmlinux.bin
> > > >   HOSTCC  arch/x86/boot/tools/build
> > > >   BUILD   arch/x86/boot/bzImage
> > > > Root device is (9, 1)
> > > > Setup is 11436 bytes (padded to 11776 bytes).
> > > > System is 2180 kB
> > > > CRC 54816509
> > > > Kernel: arch/x86/boot/bzImage is ready  (#1)
> > > >   Building modules, stage 2.
> > > >   MODPOST 136 modules
> > > > ERROR: "mii_ethtool_gset" [drivers/net/r8169.ko] undefined!
> > > > make[1]: *** [__modpost] Fehler 1
> > > > make: *** [modules] Fehler 2
> > >
> > > Francois, this is due to your commit
> > > 38d501ca6eb1f05d238bef785e51ca71dbfe0115, in the release, which w=
as a
> > > backport of ccdffb9a88b2907b159538d7bfd6256621db4f84.
> > >
> > > Care to look into this?
> >
> > R8169 needs to select MII.  You could cherry-pick
> > b73724921d906d1642f9f6d054079c6b095903fe.
>
> Yes, that looks correct, I'll do that.
>
> Volker, does this patch solve your problem?
>
> thanks,
>
> greg k-h

which patch? b73724921d906d1642f9f6d054079c6b095903fe? I don't use git&=
co and=20
I really don't know how to cherry pick one out of it. If I only have to=
 set a=20
config option - that is not a problem, just an annoyance.=20

Gl=FCck Auf
Volker

