From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: mvpp2: fix 10 Mbit/s usage
Date: Tue, 29 Jul 2014 16:48:05 -0700 (PDT)
Message-ID: <20140729.164805.1053373886252313798.davem@davemloft.net>
References: <1406496096-11039-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tawfik@marvell.com, nadavh@marvell.com,
	alior@marvell.com, jason@lakedaemon.net, andrew@lunn.ch,
	sebastian.hesselbarth@gmail.com,
	gregory.clement@free-electrons.com,
	ezequiel.garcia@free-electrons.com,
	linux-arm-kernel@lists.infradead.org
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbaG2XsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 19:48:08 -0400
In-Reply-To: <1406496096-11039-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Sun, 27 Jul 2014 23:21:35 +0200

> This commit is similar to commit 4d12bc63ab5e ("net: mvneta: fix
> operation in 10 Mbit/s mode"), but this time for the mvpp2 driver. The
> driver was properly taking into account the 1 Gbit/s and 100 Mbit/s
> speeds, but not the 10 Mbit/s, which was handled as 100
> Mbit/s. However, the MVPP2_GMAC_CONFIG_MII_SPEED bit in the
> MVPP2_GMAC_AUTONEG_CONFIG register must remain cleared to allow 10
> Mbit/s operation. This commit therefore fixes 10 Mbit/s operation.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

Applied.
