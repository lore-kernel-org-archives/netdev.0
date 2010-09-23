From: <Narendra_K@Dell.com>
Subject: RE: [PATCH] Use firmware provided index to register a network interface
Date: Thu, 23 Sep 2010 20:43:19 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE6A0AF9@blrx3m08.blr.amer.dell.com>
References: <20100922183137.GA7607@auslistsprd01.us.dell.com>	<4C9A7E39.2020304@buttersideup.com> <20100922151645.649d3d7a@nehalam> <4C9AF4EC.7020408@seoss.co.uk>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<linux-pci@vger.kernel.org>, <Matt_Domsch@Dell.com>,
	<Charles_Rose@Dell.com>, <Jordan_Hargrave@Dell.com>,
	<Vijay_Nijhawan@Dell.com>
To: <tim@seoss.co.uk>, <shemminger@vyatta.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4C9AF4EC.7020408@seoss.co.uk>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Tim Small [mailto:tim@seoss.co.uk]
> Sent: Thursday, September 23, 2010 12:04 PM
> To: Stephen Hemminger
> Cc: K, Narendra; netdev@vger.kernel.org;
linux-hotplug@vger.kernel.org;
> linux-pci@vger.kernel.org; Domsch, Matt; Rose, Charles; Hargrave,
> Jordan; Nijhawan, Vijay
> Subject: Re: [PATCH] Use firmware provided index to register a network
> interface
> 
> Stephen Hemminger wrote:
> >>> http://marc.info/?l=linux-netdev&m=125510301513312&w=2
> >> Out of interest, that link says that doing it in usespace was
> rejected,
> >> but doesn't give any references... I'd be interested to know why
> this
> >> wasn't viable - since this seemed like the best fit at first glance
> -
> >> most people will never use this, so no need to grow their kernel
> size
> >> and complexity?
> >>
> >>
> >
> > This proposal was to ad changes into every application that
> > knows about network names (iproute, iptables, snmp, quagga,
openswan,
> ...)
> > to do aliasing at the application layer.
> >
> 
> 
> OK, that's bonkers, but what I was referring to was the line in the
> linked post which said "Achieve the above in userspace only using
udev"
> - which I assumed meant to do it once in a udev rename rule by
adapting
> /etc/udev/rules.d/70-persistent-net.rules , /lib/udev/write_net_rules
> etc. - which is what I've used to enforce this sort of convention
> myself
> from time to time.
> 

Hi,

I was referring to the solution proposed in this thread -
http://marc.info/?l=linux-netdev&m=125619338904322&w=3 ([PATCH] udev:
create empty regular files to represent net). 

With regards,
Narendra K

