From: "Paul Schulz" <pschulz@foursticks.com>
Subject: RE: [Bridge] Bridging on broken Broadcom hardware.
Date: Thu, 19 Feb 2004 11:39:00 +1030
Sender: netdev-bounce@oss.sgi.com
Message-ID: <8E9CC2201AD4134E93C95C8BD6E181D4032158@adlex1.adl.foursticks.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>, "Stephen Hemminger" <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi David,

What additional information would you like to have?

Paul Schulz - Software Engineer
Foursticks Pty Ltd - Level 16, 33 King William St, Adelaide 5000
Phone: +61 8 8111 4300  Fax: +61 8 8111 4399  Mobile: +61 401 981 301
Email: pschulz@foursticks.com  Web: www.foursticks.com

-----Original Message-----
From: David S. Miller [mailto:davem@redhat.com] 
Sent: Thursday, February 19, 2004 10:59 AM
To: Stephen Hemminger
Cc: Paul Schulz; netdev@oss.sgi.com; Simon Jolly
Subject: Re: [Bridge] Bridging on broken Broadcom hardware.

On Wed, 18 Feb 2004 16:16:11 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> This looks like a network driver not bridging problem, so forwarding
to
> the netdev list.

Bridging packets, which don't come from the IP stack, won't have
CHECKSUM_HW or similar set in the SKB checksum field.  Therefore
the chip won't be told to checksum the packet on transmit.

The firmware will not mess with the packet contents at all unless
it is told to do so, and in this case (as described) it won't.

> > +	/* 5703 A2 have issues with checksumming too. (sarah) */
> > +	if (tp->pci_chip_rev_id == CHIPREV_ID_5703_A2)
> > +		tp->tg3_flags |= TG3_FLAG_BROKEN_CHECKSUMS;
> > +

I'd like to see a real errata report supporting such a claim.
