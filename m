From: Greg KH <greg@kroah.com>
Subject: Re: [stable] build error with 2.6.27.6+reiser4+ehci-hub patch.
	ERROR: "mii_ethtool_gset" [drivers/net/r8169.ko] undefined!
Date: Thu, 13 Nov 2008 20:07:32 -0800
Message-ID: <20081114040732.GB17810@kroah.com>
References: <200811140045.20166.volker.armin.hemmann@tu-clausthal.de> <20081114000725.GC19644@kroah.com> <20081114012617.GG7331@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Volker Armin Hemmann <volker.armin.hemmann@tu-clausthal.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	linux-kernel@vger.kernel.org, stable@kernel.org,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755470AbYKNEM0@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081114012617.GG7331@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 14, 2008 at 01:26:19AM +0000, Ben Hutchings wrote:
> Greg KH wrote:
> > On Fri, Nov 14, 2008 at 12:45:19AM +0100, Volker Armin Hemmann wrote:
> > > Hi,
> > > with my old config from 2.6.27.5 (which has the same patches) I get this 
> > > error:
> > > make all modules_install install
> > > <snip>
> > >   OBJCOPY arch/x86/boot/setup.bin
> > >   OBJCOPY arch/x86/boot/vmlinux.bin
> > >   HOSTCC  arch/x86/boot/tools/build
> > >   BUILD   arch/x86/boot/bzImage
> > > Root device is (9, 1)
> > > Setup is 11436 bytes (padded to 11776 bytes).
> > > System is 2180 kB
> > > CRC 54816509
> > > Kernel: arch/x86/boot/bzImage is ready  (#1)
> > >   Building modules, stage 2.
> > >   MODPOST 136 modules
> > > ERROR: "mii_ethtool_gset" [drivers/net/r8169.ko] undefined!
> > > make[1]: *** [__modpost] Fehler 1
> > > make: *** [modules] Fehler 2
> > 
> > Francois, this is due to your commit
> > 38d501ca6eb1f05d238bef785e51ca71dbfe0115, in the release, which was a
> > backport of ccdffb9a88b2907b159538d7bfd6256621db4f84.
> > 
> > Care to look into this?
> 
> R8169 needs to select MII.  You could cherry-pick
> b73724921d906d1642f9f6d054079c6b095903fe.

Yes, that looks correct, I'll do that.

Volker, does this patch solve your problem?

thanks,

greg k-h
