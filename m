From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCHv2 net-next 1/2] net: dsa: mv88e6xxx: Workaround missing PHY ID on mv88e6390
Date: Tue, 31 Jan 2017 21:49:07 -0500
Message-ID: <87r33imxr0.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1485916806-27299-1-git-send-email-andrew@lunn.ch> <1485916806-27299-2-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:56194 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750784AbdBACt5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 21:49:57 -0500
In-Reply-To: <1485916806-27299-2-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> The internal PHYs of the mv88e6390 do not have a model ID. Trap any
> calls to the ID register, and if it is zero, return the ID for the
> mv88e6390. The Marvell PHY driver can then bind to this ID.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks!

        Vivien
