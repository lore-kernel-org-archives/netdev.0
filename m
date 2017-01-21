From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 5/8] net: dsa: mv88e6xxx: Workaround missing PHY ID on mv88e6390
Date: Fri, 20 Jan 2017 19:26:31 -0500
Message-ID: <87ziildzrc.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch> <1484955062-26718-6-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:57948 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752229AbdAUA1B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 19:27:01 -0500
In-Reply-To: <1484955062-26718-6-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> The internal PHYs of the mv88e6390 do not have a model ID. Trap any
> calls to the ID register, and if it is zero, return the ID for the
> mv88e6390. The Marvell PHY driver can then bind to this ID.

This, in addition to the temperature code not working (despite what the
datasheet says) makes me wonder if this is intentional from Marvell. Do
we have a revision number for the 88E6390X's on the ZII Dev Rev C board?

It would be interesting to ask Gregory maybe about that. This looks not
"production-ready".

Other than that, I have no objection on the patch itself if that is
indeed expected from them...

Thanks,

        Vivien
