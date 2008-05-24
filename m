From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: network interface *name* alias support?
Date: Sat, 24 May 2008 11:12:47 -0700
Message-ID: <20080524111247.29d2d1e5@extreme>
References: <alpine.LNX.1.10.0805231817100.25193@fbirervta.pbzchgretzou.qr>
	<4836FB73.2010709@intel.com>
	<4837026A.6000702@hp.com>
	<1211569604.11907.37.camel@perihelion>
	<20080523225435.GT20815@postel.suug.ch>
	<1211603155.11907.79.camel@perihelion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Rick Jones <rick.jones2@hp.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jan Engelhardt <jengelh@medozas.de>, johnathan@jonmasters.org,
	netdev@vger.kernel.org, dwmw2@infradead.org
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:50505 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758371AbYEXSMx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 May 2008 14:12:53 -0400
In-Reply-To: <1211603155.11907.79.camel@perihelion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 24 May 2008 00:25:55 -0400
Jon Masters <jonathan@jonmasters.org> wrote:

> 
> On Sat, 2008-05-24 at 00:54 +0200, Thomas Graf wrote:
> > * Jon Masters <jonathan@jonmasters.org> 2008-05-23 15:06
> > > My intention is to also allow for:
> > > 
> > > ifcfg-slot_<whatever>
> > > 
> > > Where the configuration is based entirely upon what vendor <XYZ> says is
> > > the first, second, or third card. Then, those who want to use the older
> > > names can continue to do so, but those who prefer to base their
> > > configuration upon the order the vendor states, can do so.
> > 
> > I'd propose to extend the netlink configuration interface, f.e. introduce a
> > new netlink attribtue IFLA_SLOT which can be provided to select the device
> > to be changed based on the slot number instead of the name/ifindex. That
> > would also make it trivial to write a small app using RTM_GETLINK to
> > translate a slot number to the corresponding interface name.
> 
> I guess that would also work quite nicely for what I want to do, but the
> problem is that this will require either:
> 
> *). The kernel decodes the DMI extension directly.
> *). We can first inform each device which slot it is in (set the slot).
> 
> My intention is to implement whatever seems reasonable, and my reason
> for asking is that I am not a networking maintainer, so I want to know
> what seems reasonable :)
> 
> Cheers,
> 
> Jon.

If it is a physical device /sys/class/net/ethX/device is a link to
the actual device entry is /sys.



In newer kernels the contents /sys/class/net is just symlinks.
