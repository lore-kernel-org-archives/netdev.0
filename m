From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: Respect SPEED_UNFORCED, don't set force bit
Date: Thu, 17 Nov 2016 14:25:31 +1100
Message-ID: <87lgwizt1w.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1479266808-10957-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:56226 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752375AbcKQDZk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 22:25:40 -0500
In-Reply-To: <1479266808-10957-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> The SPEED_UNFORCED indicates the MAC & PHY should perform
> auto-negotiation to determine a speed which works. If this is called
> for, don't set the force bit. If it is set, the MAC actually does
> 10Gbps, why the internal PHYs don't support.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Fixes: 96a2b40c7bd3 ("net: dsa: mv88e6xxx: add port's MAC speed setter")

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

David, this is for net-next.

Thanks!

        Vivien
