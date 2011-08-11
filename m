From: Phil Blundell <philb@gnu.org>
Subject: Re: [net-next 10/10] i825xx: Move the Intel 82586/82593/82596 based
 drivers
Date: Thu, 11 Aug 2011 12:04:55 +0100
Message-ID: <1313060697.6733.111.camel@phil-desktop>
References: <1313033278-7337-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1313033278-7337-11-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@tredhat.com,
	sassmann@redhat.com, Russell King <linux@arm.linux.org.uk>,
	aris@cathedrallabs.org, Donald Becker <becker@scyld.com>,
	Chris Beauregard <cpbeaure@undergrad.math.uwaterloo.ca>,
	Richard Procter <rnp@paradise.net.nz>,
	Andries Brouwer <aeb@cwi.nl>,
	"M.Hipp" <hippm@informatik.uni-tuebingen.de>,
	Richard Hirst <richard@sleepie.demon.co.uk>,
	Sam Creasey <sammy@oh.verio.com>,
	Thomas Bogendoerfer <tsbogend@alpha.franken.de>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pbcl.net ([88.198.119.4]:37793 "EHLO hetzner.pbcl.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755338Ab1HKLgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2011 07:36:45 -0400
In-Reply-To: <1313033278-7337-11-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-08-10 at 20:27 -0700, Jeff Kirsher wrote:
> Move the drivers that use the i82586/i82593/i82596 chipsets into
> drivers/net/ethernet/i825xx/ and make the necessary Kconfig and
> Makefile changes.  There were 4 3Com drivers which were initially
> moved into 3com/, which now reside in i825xx since they all used
> the i82586 chip.

Actually, I think 3c505 was better in 3com/ where you had it before.
Although the card does use an i82586, it's front-ended by an 80186
microcontroller and that's what the driver talks to.  So there is no
meaningful code commonality with the other '586 drivers.

That said, I don't think it's a massive deal either way and if you have
a strong preference for putting it in i825xx then that's probably fine.

p.


