From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: net: generic netdev_ioaddr
Date: Sat, 30 Oct 2004 12:52:26 +0300
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1099129946.10961.9.camel@localhost>
References: <1099044244.9566.0.camel@localhost>
	 <20041029131607.GU24336@parcelfarce.linux.theplanet.co.uk>
	 <courier.418290EC.00002E85@courier.cs.helsinki.fi>
	 <m3y8hpbaf9.fsf@defiant.pm.waw.pl>
	 <20041029193827.GV24336@parcelfarce.linux.theplanet.co.uk>
	 <m3u0sdb53f.fsf@defiant.pm.waw.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@parcelfarce.linux.theplanet.co.uk>,
	davem@davemloft.net, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263662AbUJ3JvK@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
In-Reply-To: <m3u0sdb53f.fsf@defiant.pm.waw.pl>
List-Id: netdev.vger.kernel.org

Hi,

Al Viro <viro@parcelfarce.linux.theplanet.co.uk> writes:
> > What uses ->base_addr from the data returned by SIOCGIFMAP?

On Fri, 2004-10-29 at 23:13 +0200, Krzysztof Halasa wrote:
> 
> ifconfig I think:

[snip] 

> With this driver it happens to be MMIO address.
> 
> I understand presenting this value to users might have some value:
> it can help determine the physical port/card for a given netdev.
> But it should be something like a description text set by the driver
> (ie. containing PCI bus/device, or even ISA address for ISA non-PnP
> card, possibly with other information).

It seems that the user can also setup dev->base_addr with "netdev="
kernel parameter before a driver starts probing (for example
drivers/net/appletalk/cops.c). Should we get rid of "netdev=" too and
push preconfiguring down to the drivers that actually use it?

		Pekka
