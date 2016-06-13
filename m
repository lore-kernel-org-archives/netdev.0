From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RFT] net: fec: handle small PHY reset
 durations more precisely
Date: Sun, 12 Jun 2016 21:58:32 -0400 (EDT)
Message-ID: <20160612.215832.1472080008176652824.davem@davemloft.net>
References: <1465418567-2694-1-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fugang.duan@nxp.com, fabio.estevam@nxp.com, l.stach@pengutronix.de,
	andrew@lunn.ch, holgerschurig@gmail.com,
	troy.kisky@boundarydevices.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: stefan.wahren@i2se.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933059AbcFMB6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 21:58:34 -0400
In-Reply-To: <1465418567-2694-1-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Wahren <stefan.wahren@i2se.com>
Date: Wed,  8 Jun 2016 20:42:46 +0000

> Since msleep is based on jiffies the PHY reset could take longer
> than expected. So use msleep for values greater than 20 msec otherwise
> usleep_range.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>

Applied.
