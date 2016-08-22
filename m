From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 2/4] net: dsa: mv88e6xxx: Fix support for DSA tagging for older switches.
Date: Mon, 22 Aug 2016 10:41:12 -0400
Message-ID: <8737lw988n.fsf@ketchup.mtl.sfl>
References: <1471874464-16142-1-git-send-email-andrew@lunn.ch> <1471874464-16142-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jamie Lentin <jm@lentin.co.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:51123 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754209AbcHVOlP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 10:41:15 -0400
In-Reply-To: <1471874464-16142-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> Older chips only support DSA tagging on the CPU port. New devices
> support both DSA and EDSA. The driver needs to tell the core the tag
> protocol to use, and configure the switch for what is available.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

I'll send a follow-up patch to add a MV88E6XXX_FLAG_DSA flag, to prepare
support for older chips like 6060 which only support the Trailer proto.

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
