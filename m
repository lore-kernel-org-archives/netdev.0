From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [4/4] arm: mvebu: enable Ethernet controllers on Armada 370/XP
 eval boards
Date: Sun, 4 Nov 2012 10:12:12 +0100
Message-ID: <20121104101212.33449081@skate>
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
Received: from mail.free-electrons.com ([88.190.12.23]:35445 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814Ab2KDJMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Nov 2012 04:12:32 -0500
In-Reply-To: <20121104020311.GA26747@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Jason,

On Sat, 3 Nov 2012 20:03:11 -0600, Jason Gunthorpe wrote:

> We've been using the patches from Ian Molton for the mv643xx driver
> that make it use the more standard, separately described MDIO
> bus..

[...]

> Where the MDIO bus is explicit, the PHY, its address and parameters
> are explicit - the PHY has an of_node pointer - and phy-handle is used
> to connect them.
> 
> I'm not sure having the MDIO bus as a distinct top level item is
> great, considering how the registers overlap.. It might be better
> to put it under the egiga0 block? But that is a minor nit :)

Thanks for your comment. I'll see what I can come up with to make the
phy a separate DT entity.

Thanks!

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
