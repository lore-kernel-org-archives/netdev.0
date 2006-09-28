From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 (was Re: 2.6.18-mm2)
Date: Thu, 28 Sep 2006 16:30:23 -0700
Message-ID: <20060928163023.21086528@freekitty>
References: <20060928155053.7d8567ae.akpm@osdl.org>
	<451C5599.80402@garzik.org>
	<20060928162539.7d565d0a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, oe@hentges.net,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:64136 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751128AbWI1Xah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 19:30:37 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060928162539.7d565d0a.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> See also http://bugzilla.kernel.org/show_bug.cgi?id=7222
> 
> That's two reports in 18 hours, from amongst the presumably-small population
> of sky2-owning -mm testers.

I'll back it out if we don't get a simple resolution. It was just trying to
use the pci facilities as intended.

Note: I know what is causing all the sky2 problems, there is something wrong that
is causing flow control negotiation not to propagate back to all the multiple levels
of the chip. Unclear how to fix it, the documentation is not helpful on this.
If not resolved soon, I'll just force Tx flow control off for now.


-- 
Stephen Hemminger <shemminger@osdl.org>
