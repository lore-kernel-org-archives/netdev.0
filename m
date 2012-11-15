From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH v7] Network driver for the Armada 370 and Armada XP ARM
 Marvell SoCs
Date: Thu, 15 Nov 2012 08:33:19 +0100
Message-ID: <20121115083319.76483256@skate>
References: <1352905010-24172-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<20121114.215922.1242337385782766449.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, kernel@wantstofly.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	jason@lakedaemon.net, andrew@lunn.ch,
	gregory.clement@free-electrons.com, alior@marvell.com,
	dima@marvell.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:51976 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992717Ab2KOHdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 02:33:35 -0500
In-Reply-To: <20121114.215922.1242337385782766449.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

On Wed, 14 Nov 2012 21:59:22 -0500 (EST), David Miller wrote:
> From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Date: Wed, 14 Nov 2012 15:56:44 +0100
> 
> > The previous versions of this patch set have been sent on September
> > 4th (v1), October 11th (v2), October 23rd (v3), October 26th (v4),
> > November 12th (v5), November 13th (v6) and now comes the v7 of the
> > driver. The number of comments over the last versions have been really
> > small, and I would really appreciate if this driver could land into
> > the 3.8 kernel release.
> 
> I can't apply this patch to net-next, because for one thing there
> are missing dependencies.  For example, the file:
> 
> arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts
> 
> doesn't exist there, therefore patch #6 won't apply.

Yes, this is expected: those patches were provided to allow people to
test the driver on the OpenBlocks platform, which is much more widely
available than the Armada XP evaluation board from Marvell.

Would you mind if we take, with your Ack, the network driver through
the arm-soc tree, so that we can carry the related patches modifying
the Device Tree and so on? If not, then I'll send you a pull request
with just the drivers/net changes, and we'll integrate the ARM-related
changes through the arm-soc tree, in which we will have the necessary
dependencies. I'm fine with any of those solutions.

Thanks,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
