From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: sysfs question
Date: Thu, 12 Nov 2009 21:01:42 +0100
Message-ID: <20091112200141.GA281@e-circ.dyndns.org>
References: <200911021533.25345.matthias.fuchs@esd.eu> <20091106100427.GB323@e-circ.dyndns.org> <20091109112331.GE323@e-circ.dyndns.org> <4AF83EB7.3070401@grandegger.com> <20091112100053.GA322@e-circ.dyndns.org> <4AFBE0DD.1000408@grandegger.com> <20091112103940.GC322@e-circ.dyndns.org> <20091112090041.1536ccc8@nehalam> <4AFC4984.8000803@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Wolfgang Grandegger <wg@grandegger.com>, netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay011.isp.belgacom.be ([195.238.6.178]:14520 "EHLO
	mailrelay011.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753059AbZKLUBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 15:01:38 -0500
Content-Disposition: inline
In-Reply-To: <4AFC4984.8000803@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 12, 2009 at 06:44:36PM +0100, Oliver Hartkopp wrote:
> Stephen Hemminger wrote:
> > On Thu, 12 Nov 2009 11:39:41 +0100
> > Kurt Van Dijck <kurt.van.dijck@eia.be> wrote:
> > 
[...]
> > 
> > It sounds like the property you are proposing is a property of the
> > upper network layer not the hardware. Putting more properties in sysfs
> > is good if is hardware related, but awkward if it is really a protocol
> > attribute.
> 
> Then it would be good here :-)
> 
[...]
> 
> It's definitely no upper network layer stuff.
> 
Ack. It's definitely datalink or even physical layer we're talking about.
> Regards,
> Oliver

I also encountered an issue with regard to the uevent that is generated
when a netdevice is registered.
If I add sysfs files before register_netdevice, the system complains on
creating the sysfs files.
If I add those after register_netdevice, the uevent is _seems_ to have
triggered userspace already, where the udev (in fact, I use another
home-brew one for boot speed) does not find the extra sysfs file.

Is there a mechanism to hold temporarily the uevent until after the
driver has registered some extra sysfs files?

Kurt
