From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH v2 1/4] net: mvneta: driver for Marvell Armada 370/XP
 network unit
Date: Fri, 12 Oct 2012 16:59:19 +0200
Message-ID: <20121012165919.0dd085dd@skate>
References: <1349969282-12676-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<1349969282-12676-2-git-send-email-thomas.petazzoni@free-electrons.com>
	<20121011212629.GA14171@electric-eye.fr.zoreil.com>
	<20121012143131.GP12330@titan.lakedaemon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Maen Suleiman <maen@marvell.com>,
	Rami Rosen <rosenr@marvell.com>
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:44965 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757391Ab2JLO7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 10:59:34 -0400
In-Reply-To: <20121012143131.GP12330@titan.lakedaemon.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason,

On Fri, 12 Oct 2012 10:31:31 -0400, Jason Cooper wrote:

> I agree with Francois on most of these.  I prefer readability over
> hard 80 column limits.

Sure, but checkpatch.pl is warning on every line exceeding the 80
columns. Not that I think that all checkpatch.pl warnings should
necessarily be religiously respected, but if you have gazillions of
warnings regarding line exceeding 80 columns, it is very likely that
you will miss more important warnings.

> Although, 80 columns is still sound
> guidance.  For example, a majority of the broken lines are due to
> long macro and constant names.  I did a 'git grep NETA' and didn't
> see anything alarming.  So, above could become
> 
> 			val |= rx_filled << NETA_RXQ_ADD_NONOCC_SHIFT;

I don't mind, but then I would like to keep things consistent:

 * The driver file would be neta.c

 * All functions and data structure would be prefixed neta_ and not
   mvneta_

 * The Kconfig option would become CONFIG_NETA. Do we really want such
   a "simple" Kconfig option name for a driver?

Also, this is entirely not consistent with the existing mv643xx_eth
driver, which has kept the "mv" part of the prefix.

Maybe the fact that those long macros are making long lines is also due
to the code having sometimes a too deep indentation, and I need to fix
that by using more auxiliary functions or something like that?

Thanks,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
