From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/8] can: Driver for the SJA1000 CAN controller
Date: Fri, 20 Feb 2009 00:46:32 -0800 (PST)
Message-ID: <20090220.004632.226039985.davem@davemloft.net>
References: <1235070082-7069-4-git-send-email-wg@grandegger.com>
	<1235070082-7069-5-git-send-email-wg@grandegger.com>
	<20090219171440.0c8286a1@bike.lwn.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, oliver.hartkopp@volkswagen.de
To: corbet@lwn.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32983
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752790AbZBTIqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 03:46:51 -0500
In-Reply-To: <20090219171440.0c8286a1@bike.lwn.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonathan Corbet <corbet@lwn.net>
Date: Thu, 19 Feb 2009 17:14:40 -0700

> I won't be able to look at all of these...
> 
> > diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> > index d609895..78a412b 100644
> > --- a/drivers/net/can/Kconfig
> > +++ b/drivers/net/can/Kconfig
> > @@ -35,6 +35,17 @@ config CAN_CALC_BITTIMING
> >  	  files "tq", "prop_seg", "phase_seg1", "phase_seg2" and "sjw".
> >  	  If unsure, say Y.
> >  
> > +config CAN_SJA1000
> > +	depends on CAN_DEV
> > +	tristate "Philips SJA1000"
> > +	---help---
> > +	  The SJA1000 is one of the top CAN controllers out there. As it
> > +	  has a multiplexed interface it fits directly to 8051
> > +	  microcontrollers or into the PC I/O port space. The SJA1000
> > +	  is a full CAN controller, with shadow registers for RX and TX.
> > +	  It can send and receive any kinds of CAN frames (SFF/EFF/RTR)
> > +	  with a single (simple) filter setup.
> 
> This sounds more like advertising text.  But what people need to know is
> whether they should enable it or not.

Totally agreed, this Kconfig help text is inappropriate
at best.
