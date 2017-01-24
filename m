From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 1/5] net: dsa: mv88e6xxx: Abstract mv88e6165 PHY operations
Date: Tue, 24 Jan 2017 10:56:57 -0500
Message-ID: <874m0ocuye.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1485266031-4980-1-git-send-email-andrew@lunn.ch> <1485266031-4980-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34048 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbdAXP5a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 10:57:30 -0500
In-Reply-To: <1485266031-4980-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> The mv88e6165 family has the internal PHYs mapped directly onto the
> SMI register space as the switch. So the registers can be read
> directly. Put a wrapper around this, in preparation for changing the
> signature in order to support the external MDIO bus of the 6390.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
