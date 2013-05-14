From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] mv643xx_eth: fix NAPI weight being > 64
Date: Tue, 14 May 2013 11:33:19 -0700 (PDT)
Message-ID: <20130514.113319.1597275156031821180.davem@davemloft.net>
References: <1368525260-17556-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jason@lakedaemon.net, buytenh@wantstofly.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43558 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755499Ab3ENSdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 14:33:20 -0400
In-Reply-To: <1368525260-17556-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 14 May 2013 11:54:20 +0200

> 3.10-rc1 issues the following warning:
> 
> netif_napi_add() called with weight 128 on device eth%d
> 
> This patch reduce the weight to 64, using NAPI_POLL_WEIGHT.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied.
