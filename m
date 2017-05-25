From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 1/5] net: dsa: mv88e6xxx: Move phy functions
 into phy.[ch]
Date: Thu, 25 May 2017 12:35:23 -0400 (EDT)
Message-ID: <20170525.123523.1266499465656377430.davem@davemloft.net>
References: <1495573486-31827-1-git-send-email-andrew@lunn.ch>
        <1495573486-31827-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59006 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751861AbdEYQfY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 12:35:24 -0400
In-Reply-To: <1495573486-31827-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Tue, 23 May 2017 23:04:42 +0200

> The upcoming SERDES support will need to make use of PHY functions. Move
> them out into a file of there own. No code changes.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Please unexport mv88e6xxx_phy_page_get and mv88e6xxx_phy_page_put, as noted
by Vivien they are not used outside of phy.c

Thank you.
