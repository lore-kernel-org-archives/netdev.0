From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: Respect SPEED_UNFORCED, don't set
 force bit
Date: Wed, 16 Nov 2016 14:34:30 -0500 (EST)
Message-ID: <20161116.143430.190220412883737135.davem@davemloft.net>
References: <1479266808-10957-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48810 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752897AbcKPTec (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 14:34:32 -0500
In-Reply-To: <1479266808-10957-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 16 Nov 2016 04:26:48 +0100

> The SPEED_UNFORCED indicates the MAC & PHY should perform
> auto-negotiation to determine a speed which works. If this is called
> for, don't set the force bit. If it is set, the MAC actually does
> 10Gbps, why the internal PHYs don't support.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

What tree is this for?  This is a fix but the patch doesn't apply to
'net'.
