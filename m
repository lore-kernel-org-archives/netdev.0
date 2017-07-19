From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: Enable CMODE config support for 6390X
Date: Wed, 19 Jul 2017 12:55:11 -0400
Message-ID: <87d18wfjtc.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20170719061702.7692-1-mnhu@prevas.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Martin =?utf-8?Q?Hundeb=C3=B8ll?= <mnhu@prevas.dk>,
        netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: Martin =?utf-8?Q?Hundeb=C3=B8ll?= <mnhu@prevas.dk>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:59590 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753094AbdGSQ5z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 12:57:55 -0400
In-Reply-To: <20170719061702.7692-1-mnhu@prevas.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin Hundebøll <mnhu@prevas.dk> writes:

> Commit f39908d3b1c45 ('net: dsa: mv88e6xxx: Set the CMODE for mv88e6390
> ports 9 & 10') added support for setting the CMODE for the 6390X family,
> but only enabled it for 9290 and 6390 - and left out 6390X.
>
> Fix support for setting the CMODE on 6390X also by assigning
> mv88e6390x_port_set_cmode() to the .port_set_cmode function pointer in
> mv88e6390x_ops too.
>
> Signed-off-by: Martin Hundebøll <mnhu@prevas.dk>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
