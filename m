From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 2.6.25 1/1]S2io: Multiqueue network device support implementation
Date: Thu, 24 Jan 2008 22:19:45 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7702E713B1@nekter>
References: <20080124072549.GA6814@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	<netdev@vger.kernel.org>, <jeff@garzik.org>,
	"support" <support@neterion.com>
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:46552 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751573AbYAYDVR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 22:21:17 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080124072549.GA6814@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > [Ram] I am assuming that this is with regards to msi-x interrupts.
We
> 
> Yes.
> 
> And avoiding bouncing locks for device state between CPUs.
> 
> > have done away with handling tx completion in the interrupt handler,
and
> > are instead handling them in the context of the transmit. The slow
path,
> > straggling transmit completions will be handled in the timer
context.
> 
> Ok -- hopefully you don't have bad corner cases from this when the
pipe
> is not fully filled and then causing longer latencies on completion.
> Old NAPI sometimes suffered from such problems.
[Ram] We have hit the driver pretty hard during testing and have not
encountered any problems either on the network or host.

Ram
> 
> -Andi
