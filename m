From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ethernet: mvneta: Remove IFF_UNICAST_FLT
 which is not implemented
Date: Fri, 25 Nov 2016 19:59:33 -0500 (EST)
Message-ID: <20161125.195933.694389582684212468.davem@davemloft.net>
References: <1479942493-19784-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57668 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751968AbcKZA7g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 19:59:36 -0500
In-Reply-To: <1479942493-19784-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Thu, 24 Nov 2016 00:08:13 +0100

> The mvneta driver advertises it supports IFF_UNICAST_FLT. However, it
> actually does not. The hardware probably does support it, but there is
> no code to configure the filter. As a quick and simple fix, remove the
> flag. This will cause the core to fall back to promiscuous mode.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Fixes: b50b72de2f2f ("net: mvneta: enable features before registering the driver")

Applied.
