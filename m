From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: phy: Use interrupts when available in
 NOLINK state
Date: Tue, 17 Nov 2015 15:26:18 -0500 (EST)
Message-ID: <20151117.152618.1114245640009825489.davem@davemloft.net>
References: <1447713406-26137-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882AbbKQU0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 15:26:21 -0500
In-Reply-To: <1447713406-26137-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 16 Nov 2015 23:36:46 +0100

> The NOLINK state will poll the phy once a second to see if the link
> has come up. If the phy has an interrupt line, this polling can be
> skipped, since the phy should interrupt when the link returns.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied.
