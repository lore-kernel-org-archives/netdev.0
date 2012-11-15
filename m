From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7] Network driver for the Armada 370 and Armada XP ARM
 Marvell SoCs
Date: Wed, 14 Nov 2012 21:59:22 -0500 (EST)
Message-ID: <20121114.215922.1242337385782766449.davem@davemloft.net>
References: <1352905010-24172-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, kernel@wantstofly.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	jason@lakedaemon.net, andrew@lunn.ch,
	gregory.clement@free-electrons.com, alior@marvell.com,
	dima@marvell.com
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38703 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933136Ab2KOC7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 21:59:24 -0500
In-Reply-To: <1352905010-24172-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Wed, 14 Nov 2012 15:56:44 +0100

> The previous versions of this patch set have been sent on September
> 4th (v1), October 11th (v2), October 23rd (v3), October 26th (v4),
> November 12th (v5), November 13th (v6) and now comes the v7 of the
> driver. The number of comments over the last versions have been really
> small, and I would really appreciate if this driver could land into
> the 3.8 kernel release.

I can't apply this patch to net-next, because for one thing there
are missing dependencies.  For example, the file:

arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts

doesn't exist there, therefore patch #6 won't apply.
