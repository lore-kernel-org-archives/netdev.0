From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/12] at91_ether cleanup
Date: Fri, 19 Oct 2012 13:48:32 -0400 (EDT)
Message-ID: <20121019.134832.1221504804550166119.davem@davemloft.net>
References: <1350594079-4337-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org
To: manabian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37132 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758807Ab2JSRse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 13:48:34 -0400
In-Reply-To: <1350594079-4337-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joachim Eastwood <manabian@gmail.com>
Date: Thu, 18 Oct 2012 23:01:05 +0200

> This patch series prepares the old at91_ether driver for code
> sharing with the macb driver. The hardware is similar except for DMA
> TX/RX, so its not quite clear if it is practical to support both in
> one driver. But stuff like MDIO and statistics should be possible to
> share.

All applied, thanks.

Can you get rid of that HAVE_NET_MACB thing?  It's completely
pointless.  This is a platform driver for crying out loud,
therefore it can successfully build on any architecture.  And
we want this exposed for build testing as far as we can.

Thanks.
