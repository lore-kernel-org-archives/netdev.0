From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Fixes for port refactoring
Date: Thu, 10 Nov 2016 13:05:41 -0500 (EST)
Message-ID: <20161110.130541.964567980913112319.davem@davemloft.net>
References: <1478789041-16264-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35830 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751674AbcKJSFo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 13:05:44 -0500
In-Reply-To: <1478789041-16264-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Thu, 10 Nov 2016 15:43:59 +0100

> The patches which refactored setting up the switch MACs introduced a
> couple of regressions. The RGMII delays for a port can be set using
> other mechanism than just phy-mode. Don't overwrite the delays unless
> explicitly asked to. This broke my Armada 370 RD. Also, the mv88e6351
> family supports setting RGMII delays, but is missing the necessary
> entries in the ops structures to allow this.
> 
> These fixes are to patches currently in net-next. No need for stable
> etc.

Series applied, thanks Andrew.
