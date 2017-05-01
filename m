From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: fix phy interrupt parsing
Date: Sun, 30 Apr 2017 22:22:31 -0400 (EDT)
Message-ID: <20170430.222231.646218187767031758.davem@davemloft.net>
References: <20170426100628.14493-1-alexandre.belloni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@microchip.com, bfolta@cadence.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: alexandre.belloni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54094 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S642254AbdEACWn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 22:22:43 -0400
In-Reply-To: <20170426100628.14493-1-alexandre.belloni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Date: Wed, 26 Apr 2017 12:06:28 +0200

> Since 83a77e9ec415, the phydev irq is explicitly set to PHY_POLL when
> there is no pdata. It doesn't work on DT enabled platforms because the
> phydev irq is already set by libphy before.
> 
> Fixes: 83a77e9ec415 ("net: macb: Added PCI wrapper for Platform Driver.")
> Signed-off-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>

Applied and queued up for -stable, thanks.
