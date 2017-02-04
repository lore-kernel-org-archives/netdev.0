From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: Add watchdog interrupt handler
Date: Sat, 04 Feb 2017 16:09:19 -0500
Message-ID: <87r33doe80.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1486240734-13157-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:47642 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750944AbdBDVJ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 16:09:57 -0500
In-Reply-To: <1486240734-13157-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> The switch contains a watchdog looking for issues with the internal
> gubbins of the switch. Hook the interrupt the watchdog triggers and
> log the value of the control register indicating why the watchdog
> fired. The watchdog can only be cleared with a switch reset, which
> will destroy the current configuration. Rather than doing this, just
> disable the interrupt.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
