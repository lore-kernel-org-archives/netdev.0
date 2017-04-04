From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net/faraday: Add missing include of of.h
Date: Mon, 03 Apr 2017 18:58:47 -0700 (PDT)
Message-ID: <20170403.185847.541767208411100424.davem@davemloft.net>
References: <1491157247-5072-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53136 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751362AbdDDB6t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 21:58:49 -0400
In-Reply-To: <1491157247-5072-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sun,  2 Apr 2017 20:20:47 +0200

> Breaking the include loop netdevice.h, dsa.h, devlink.h broke this
> driver, it depends on includes brought in by these headers. Adding
> linux/of.h fixes it.
> 
> Fixes: ed0e39e97d34 ("net: break include loop netdevice.h, dsa.h, devlink.h")
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks.
