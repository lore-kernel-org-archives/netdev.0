From: Michael Buesch <mb@bu3sch.de>
Subject: Re: recommend a network card
Date: Sun, 18 Jun 2006 17:48:55 +0200
Message-ID: <200606181748.55398.mb@bu3sch.de>
References: <BAY101-F198A641697A687C99F13FEC8810@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:47323
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751200AbWFRPty
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jun 2006 11:49:54 -0400
To: "bastard operater" <bofh1234@hotmail.com>
In-Reply-To: <BAY101-F198A641697A687C99F13FEC8810@phx.gbl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 18 June 2006 17:28, bastard operater wrote:
> >I never had a malfunctioning NIC. What does it look like?
> >Broken packages?
> 
> It loses its network connection (the systems says the card is unplugged) for 
> a second or two and then the connection comes back.  Sometimes the 
> connection just stops working  and I have to restart the network service.

uh, oh. Interresting.
Sure it is not a software bug in PCI hotplug or something?
(or something accidentally poking with fakephp)

I would test the card in another machine, before throwing it away.

> > > I am in the market for a new NIC.  The card has to work on Linux 
> >(natively)
> > > and windows.  I thought I would ask the experts if you have any
> > > recommendations for a good 100MB PCI card?
> >
> >I have mostly RTL based cards (ranging from 10 to 1000 mbit).
> >No problems so far. (But also no problem with my 3c905 since
> >quite some time ;) )
> 
> How can I tell which cards use which chipset?

Look at the chip ;)
One of my cards (100mbit) has a chip with the string
RTL8139D
printed on it.
There's usually only one or two chips on the card. You can't miss it.
It's the chip, which is connected directly to the PCI pins.

btw: This is not really the right list to ask such questions,
     as it is not development related, but well... :)

-- 
Greetings Michael.
