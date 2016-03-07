From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ethoc: do not free array priv->mdio->irq
Date: Sun, 06 Mar 2016 22:59:39 -0500 (EST)
Message-ID: <20160306.225939.1421418316785928745.davem@davemloft.net>
References: <1457012614-19564-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, tklauser@distanz.ch,
	fabf@skynet.be, jcmvbkbc@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43036 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbcCGD7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 22:59:41 -0500
In-Reply-To: <1457012614-19564-1-git-send-email-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Thu,  3 Mar 2016 13:43:34 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> priv->mdio->irq used to be allocated and required freeing, but it
> is now a fixed sized array and should no longer be free'd.
> 
> Issue detected using static analysis with CoverityScan
> 
> Fixes: e7f4dc3536a400 ("mdio: Move allocation of interrupts into core")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
