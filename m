From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 3/4] dsa: mv88e6xxx: Delete ppu timer when removing module
Date: Mon, 22 Aug 2016 10:51:03 -0400
Message-ID: <87zio47t7s.fsf@ketchup.mtl.sfl>
References: <1471874464-16142-1-git-send-email-andrew@lunn.ch> <1471874464-16142-4-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jamie Lentin <jm@lentin.co.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:51724 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755470AbcHVOvI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 10:51:08 -0400
In-Reply-To: <1471874464-16142-4-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> The PPU method of accessing PHYs makes use of a timer. Make sure this
> timer is deleted before unloading the driver.
>
> Reported-by: Jamie Lentin <jm@lentin.co.uk>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

I'm wondering if the PPU shouldn't be disabled before unloading the
module... Otherwise:

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
