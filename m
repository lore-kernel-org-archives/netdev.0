From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dsa: Support multiple MDIO busses
Date: Mon, 10 Aug 2015 14:25:28 -0700 (PDT)
Message-ID: <20150810.142528.1928487768038067449.davem@davemloft.net>
References: <1439046554-9669-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44442 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932726AbbHJVZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 17:25:29 -0400
In-Reply-To: <1439046554-9669-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sat,  8 Aug 2015 17:09:14 +0200

> When using a cluster of switches, some topologies will have an MDIO
> bus per switch, not one for the whole cluster. Allow this to be
> represented in the device tree, by adding an optional mii-bus property
> at the switch level. The old platform_device method of instantiation
> supports this already, so only the device tree binding needs extending
> with an additional optional phandle.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Also applied, thanks Andrew.
