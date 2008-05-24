From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: network interface *name* alias support?
Date: Sat, 24 May 2008 00:25:55 -0400
Message-ID: <1211603155.11907.79.camel@perihelion>
References: <alpine.LNX.1.10.0805231817100.25193@fbirervta.pbzchgretzou.qr>
	 <4836FB73.2010709@intel.com> <4837026A.6000702@hp.com>
	 <1211569604.11907.37.camel@perihelion>
	 <20080523225435.GT20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jan Engelhardt <jengelh@medozas.de>, johnathan@jonmasters.org,
	netdev@vger.kernel.org, dwmw2@infradead.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dallas.jonmasters.org ([72.29.103.172]:43089 "EHLO
	dallas.jonmasters.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbYEXE0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2008 00:26:15 -0400
In-Reply-To: <20080523225435.GT20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 2008-05-24 at 00:54 +0200, Thomas Graf wrote:
> * Jon Masters <jonathan@jonmasters.org> 2008-05-23 15:06
> > My intention is to also allow for:
> > 
> > ifcfg-slot_<whatever>
> > 
> > Where the configuration is based entirely upon what vendor <XYZ> says is
> > the first, second, or third card. Then, those who want to use the older
> > names can continue to do so, but those who prefer to base their
> > configuration upon the order the vendor states, can do so.
> 
> I'd propose to extend the netlink configuration interface, f.e. introduce a
> new netlink attribtue IFLA_SLOT which can be provided to select the device
> to be changed based on the slot number instead of the name/ifindex. That
> would also make it trivial to write a small app using RTM_GETLINK to
> translate a slot number to the corresponding interface name.

I guess that would also work quite nicely for what I want to do, but the
problem is that this will require either:

*). The kernel decodes the DMI extension directly.
*). We can first inform each device which slot it is in (set the slot).

My intention is to implement whatever seems reasonable, and my reason
for asking is that I am not a networking maintainer, so I want to know
what seems reasonable :)

Cheers,

Jon.


