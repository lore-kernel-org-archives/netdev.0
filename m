From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [4/4] arm: mvebu: enable Ethernet controllers on Armada 370/XP
 eval boards
Date: Mon, 12 Nov 2012 18:30:07 +0100
Message-ID: <20121112183007.281970f5@skate>
References: <1351245804-31478-5-git-send-email-thomas.petazzoni@free-electrons.com>
	<20121104020311.GA26747@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Maen Suleiman <maen@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Ian Molton <ian.molton@codethink.co.uk>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:40775 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901Ab2KLRad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2012 12:30:33 -0500
In-Reply-To: <20121104020311.GA26747@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason,

On Sat, 3 Nov 2012 20:03:11 -0600, Jason Gunthorpe wrote:

> We've been using the patches from Ian Molton for the mv643xx driver
> that make it use the more standard, separately described MDIO
> bus..
> 
> Please consider not copying the unsual 'phy-addr' binding
> for the new driver.

I have just sent a fifth version of the patch set that implements a
separate DT node for the PHY devices, as well as a separate MDIO bus.

Please let me know if it solves your comment.

Thanks!

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
