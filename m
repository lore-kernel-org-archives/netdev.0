From: Milton Miller <miltonm@bga.com>
Subject: Re: [PATCH 1/2] Remove REDWOOD_[456] config options and conditional code
Date: Fri, 16 Jul 2010 10:45:27 -0500
Message-ID: <redwood56-reply-2-miltonm@bga.com>
References: <4f07b3092cafbbba37d61d367cc7484e24d18d2a.1279116162.git.qy03fugy@stud.informatik.uni-erlangen.de>
	<ae6929d3206f6a282f2b0bf2621a05af45d892ff.1279282865.git.qy03fugy@stud.informatik.uni-erlangen.de>
	<ca1bb25d203618c3548748f5efb6f125a96c89e0.1279282865.git.qy03fugy@stud.informatik.uni-erlangen.de>
	<redwood56-reply-1-miltonm@bga.com>
	<cover.1279282865.git.qy03fugy@stud.informatik.uni-erlangen.de>
	<20100716142055.GA11736@zod.rchland.ibm.com>
Cc: Milton Miller <miltonm@bga.com>,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>,
	Matt Porter <mporter@kernel.crashing.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Solomon Peachy <solomon@linux-wlan.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Mike Frysinger <vapier@gentoo.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Artem Bityutskiy <Artem.Bityutskiy@nokia.com>,
	Alexander Kurz <linux@kbdbabel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	John Linn <john.linn@xilinx.com>,
	Florian Fainelli <florian@openwrt.org>,
	Nicolas Pitre <nico@fluxnic.net>,
	Joe Perches <joe@perches.com>,
	Ladislav Michl <ladis@linux-mips.org>,
	David Brown <davidb@quicinc.com>, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org,
	netdev@vger.kernel.org, vamos-dev@i4.informatik.uni-erlangen.de
To: Christian Dietrich <qy03fugy@stud.informatik.uni-erlangen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100716142055.GA11736@zod.rchland.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 16 Jul 2010 at about 08:20:55 -0600 Josh Boyer wrote:
> On Fri, Jul 16, 2010 at 02:29:02PM +0200, Christian Dietrich wrote: 
> > The config options for REDWOOD_[456] were commented out in the powerpc
> > Kconfig. The ifdefs referencing this options therefore are dead and all
> > references to this can be removed (Also dependencies in other KConfig
> > files).

> This seems fine with me.
> 
> The only question is which tree it coms through. I'm happy to take it
> in via mine if the netdev and MTD people are fine with that. Otherwise,
> my ack is below.


> On Fri, 16 Jul 2010 around 14:29:08 +0200 Christian Dietrich wrote:
> > diff --git a/drivers/mtd/maps/Kconfig b/drivers/mtd/maps/Kconfig
> > index f22bc9f..6629d09 100644
> > --- a/drivers/mtd/maps/Kconfig
> > +++ b/drivers/mtd/maps/Kconfig
> > @@ -321,7 +321,7 @@ config MTD_CFI_FLAGADM
> > 
> >  config MTD_REDWOOD
> >  	tristate "CFI Flash devices mapped on IBM Redwood"
> > -	depends on MTD_CFI && ( REDWOOD_4 || REDWOOD_5 || REDWOOD_6 )
> > +	depends on MTD_CFI
> >  	help
> >  	  This enables access routines for the flash chips on the IBM
> >  	  Redwood board. If you have one of these boards and would like to
> > diff --git a/drivers/mtd/maps/redwood.c b/drivers/mtd/maps/redwood.c
> > index 933c0b6..d2c9db0 100644
> > --- a/drivers/mtd/maps/redwood.c
> > +++ b/drivers/mtd/maps/redwood.c
> > @@ -22,8 +22,6 @@

The patches are unnecssarly coupled by removing the REDWOOD_* symbols
in the MTD area before removing the files and Kconfig completely in
the second patch.  This could easily be eliminated by pushing the
two fragments into the second patch.

milton
