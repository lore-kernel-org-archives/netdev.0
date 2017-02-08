From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCHv2 net-next 0/2] mv88e6xxx Watchdog support
Date: Wed, 08 Feb 2017 11:34:52 -0500
Message-ID: <87a89wwsib.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1486514080-28329-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:42994 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752834AbdBHQfo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 11:35:44 -0500
In-Reply-To: <1486514080-28329-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> The Marvell switches have an in built watchdog over some of the
> internal state machine. The watchdog can be configured to raise an
> interrupt on error. The problem the watchdog found is then logged to
> the kernel log.
>
> The older switches can automagically perform a software reset when the
> watchdog triggers. This just resets the internal state machine, but
> leaves the switch configuration unchanged.
>
> The 6390 family of switches cannot both raise an interrupt and
> automagically perform a software reset. So the interrupt handler has
> to perform the switch reset, and then re-enable the watchdog
> interrupts.
>
> This has been tested using hacked together debugfs code which allows
> the "force" bit to be set, so cause a watchdog interrupt.

Please remove the "g2_" prefix in the mv88e6xxx_ops members...

Thanks,

        Vivien
