From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: Fix three oopses in PHY {de,}initialization
 code
Date: Fri, 27 Mar 2009 16:00:29 -0700 (PDT)
Message-ID: <20090327.160029.157396274.davem@davemloft.net>
References: <20090327174047.GA23111@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joakim.Tjernlund@transmode.se, leoli@freescale.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49360
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754927AbZC0XAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 19:00:41 -0400
In-Reply-To: <20090327174047.GA23111@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Fri, 27 Mar 2009 20:40:47 +0300

> When there are no free snums, UCC ethernet should gracefully fail, but
> currently it oopses this way:
 ...
> Also, when device tree specifies fixed-link, and CONFIG_FIXED_PHY
> is disabled, we'll get this oops:
 ...
> This patch fixes all three oopses simply by rearranging some code:
> 
> - In ucc_geth_open(): move init_phy() call to the beginning, so
>   that we only call ucc_geth_stop() with a PHY attached;
> - Move phy_disconnect() call from ucc_geth_close() to
>   ucc_geth_stop(), so that we'll always disconnect the PHY.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied, thanks Anton.
