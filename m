From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH net v2] net: smc91x: Fix build without gpiolib
Date: Fri, 12 Dec 2014 08:34:54 -0800
Message-ID: <20141212163454.GI2950@atomide.com>
References: <20141212161100.GH2950@atomide.com>
 <20141212.112119.1395396406830853805.davem@davemloft.net>
 <20141212162746.GJ16916@distanz.ch>
 <20141212.113020.884577050283133272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tklauser@distanz.ch, nico@fluxnic.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:57112 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030611AbaLLQiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 11:38:04 -0500
Content-Disposition: inline
In-Reply-To: <20141212.113020.884577050283133272.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller <davem@davemloft.net> [141212 08:32]:
> From: Tobias Klauser <tklauser@distanz.ch>
> Date: Fri, 12 Dec 2014 17:27:46 +0100
> 
> > GPIO is not needed in all configurations of the chip, they are optional.
> > That's why I was going for the ugly #ifdef solution.
> > 
> > It seems that there are stubs for the functions in question in
> > linux/gpio/consumer.h already as Tony suggested. Thus, adding an
> > #include <linux/gpio/consumer.h> to the driver should be enough. I'll
> > send an updated patch.
> 
> So for the "configurations" that need it, how does the user figure out
> that GPIO is needed?
> 
> In my opinion, if the code blocks enabling the configurations that
> need this are enabled, so should GPIO be depended upon.
> 
> I think, at a minimum, when CONFIG_OF is enabled smsc91x should
> require GPIO.

Well in many cases these control GPIOs, or some part of them, are
hardwired with pulls. That's why they are optional.

Regards,

Tony
