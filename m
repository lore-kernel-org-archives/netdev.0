From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mv643xx_eth: fix NAPI weight being > 64
Date: Tue, 14 May 2013 00:48:02 -0700 (PDT)
Message-ID: <20130514.004802.2003665831321985333.davem@davemloft.net>
References: <1368508632-13742-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, jason@lakedaemon.net,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35524 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756399Ab3ENHsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 03:48:03 -0400
In-Reply-To: <1368508632-13742-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 14 May 2013 07:17:12 +0200

> 3.10-rc1 issues the following warning:
> 
> netif_napi_add() called with weight 128 on device eth%d
> 
> This patch reduce the weight to 64.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

We have a macro, NAPI_POLL_WEIGHT, for this, please use it.
