From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCHv2 net-next 0/2] Preparation for mv88e6390
Date: Mon, 19 Sep 2016 22:18:57 -0400
Message-ID: <87mvj3qpny.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <1474331590-7959-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:40530 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752126AbcITCTB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 22:19:01 -0400
In-Reply-To: <1474331590-7959-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> These two patches are a couple of preparation steps for supporting the
> the MV88E6390 family of chips. This is a new generation from Marvell,
> and will need more feature flags than are currently available in an
> unsigned long. Expand to an unsigned long long. The MV88E6390 also
> places its port registers somewhere else, so add a wrapper around port
> register access.
>
> v2: Rework wrappers to use mv88e6xxx_{read|write}
>     Simpliy some (err < ) to (err)
>     Add Reviewed by tag.
>
> Andrew Lunn (2):
>   net: dsa: mv88e6xxx: Convert flag bits to unsigned long long
>   WIP: net: dsa: mv88e6xxx: Implement interrupt support.

Since there's a need for a v3, note that the above summary is wrong.

Thanks,

        Vivien
