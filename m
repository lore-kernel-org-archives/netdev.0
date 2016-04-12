From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: mdio: Fix lockdep falls positive splat
Date: Mon, 11 Apr 2016 21:27:09 -0400 (EDT)
Message-ID: <20160411.212709.1610168975220105015.davem@davemloft.net>
References: <1460403605-31882-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	vivien.didelot@savoirfairelinux.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38623 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755194AbcDLB1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 21:27:12 -0400
In-Reply-To: <1460403605-31882-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Mon, 11 Apr 2016 21:40:05 +0200

> MDIO devices can be stacked upon each other. The current code supports
> two levels, which until recently has been enough for a DSA mdio bus on
> top of another bus. Now we have hardware which has an MDIO mux in the
> middle.
> 
> Define an MDIO MUTEX class with three levels.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks Andrew.
