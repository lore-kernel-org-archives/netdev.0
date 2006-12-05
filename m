From: Dan Nicolaescu <dann@ics.uci.edu>
Subject: Re: [RFC patch] driver for the Opencores Ethernet Controller
Date: Tue, 05 Dec 2006 13:42:34 -0800
Message-ID: <200612052142.kB5LgYNN016752@oogie-boogie.ics.uci.edu>
References: <200612041801.kB4I11F4018165@oogie-boogie.ics.uci.edu>
	<20061204180734.GA21561@xi.wantstofly.org>
	<200612041827.kB4IRqrW019090@oogie-boogie.ics.uci.edu>
	<20061205000709.GA23299@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oogie-boogie.ics.uci.edu ([128.195.1.41]:64489 "EHLO
	oogie-boogie.ics.uci.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758916AbWLEVst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 16:48:49 -0500
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20061205000709.GA23299@xi.wantstofly.org> (Lennert Buytenhek's message of "Tue\, 5 Dec 2006 01\:07\:09 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek <buytenh@wantstofly.org> writes:

  > On Mon, Dec 04, 2006 at 10:27:52AM -0800, Dan Nicolaescu wrote:
  > 
  > > > > The Opencores Ethernet Controller is Verilog code that can be used to
  > > > > implement an Ethernet device in hardware. It needs to be coupled with
  > > > > a PHY and some buffer memory. Because of that devices that implement
  > > > > this controller can be very different. The code here tries to support
  > > > > that by having some parameters that need to be defined at compile
  > > > > time.
  > > > 
  > > > Considering this, why don't you make it a platform driver?
  > > 
  > > I didn't know about "platform drivers" before your mail. I guess I
  > > could convert it to that if that is the right thing to do. 
  > 
  > I definitely think so.  Check the ep93xx_eth driver for an example.
  > 
  > 
  > > (It might be an overkill given that the device is kind of simple and
  > > embedded people prefer small code...)
  > 
  > ..until someone decides that he wants to build a design with two of
  > these ethernet cores instead of just one, at which point the entire
  > "Let's use #defines for everything" plan breaks down badly.

Sure.  If changing the code to implement a platform driver is required
in order to get it accepted, then I'll do that. If it's not required,
the platform driver code can be added later as an incremental patch.



