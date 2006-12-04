From: Dan Nicolaescu <dann@ics.uci.edu>
Subject: Re: [RFC patch] driver for the Opencores Ethernet Controller
Date: Mon, 04 Dec 2006 10:27:52 -0800
Message-ID: <200612041827.kB4IRqrW019090@oogie-boogie.ics.uci.edu>
References: <200612041801.kB4I11F4018165@oogie-boogie.ics.uci.edu>
	<20061204180734.GA21561@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oogie-boogie.ics.uci.edu ([128.195.1.41]:50419 "EHLO
	oogie-boogie.ics.uci.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937229AbWLDSaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 13:30:39 -0500
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20061204180734.GA21561@xi.wantstofly.org> (Lennert Buytenhek's message of "Mon\, 4 Dec 2006 19\:07\:36 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek <buytenh@wantstofly.org> writes:

  > On Mon, Dec 04, 2006 at 10:01:01AM -0800, Dan Nicolaescu wrote:
  > 
  > > The Opencores Ethernet Controller is Verilog code that can be used to
  > > implement an Ethernet device in hardware. It needs to be coupled with
  > > a PHY and some buffer memory. Because of that devices that implement
  > > this controller can be very different. The code here tries to support
  > > that by having some parameters that need to be defined at compile
  > > time.
  > 
  > Considering this, why don't you make it a platform driver?

I didn't know about "platform drivers" before your mail. I guess I
could convert it to that if that is the right thing to do. 
(It might be an overkill given that the device is kind of simple and
embedded people prefer small code...)

Any comments on the driver itself? 

Thanks
        --dan
