From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/2] mv88e6xxx Watchdog support
Date: Mon, 13 Feb 2017 09:30:45 -0500 (EST)
Message-ID: <20170213.093045.2293700707099754308.davem@davemloft.net>
References: <1486595023-28371-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43574 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751945AbdBMOaw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 09:30:52 -0500
In-Reply-To: <1486595023-28371-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Thu,  9 Feb 2017 00:03:41 +0100

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
> 
> v2: Remove g2_prefix

Series applied, thanks Andrew.
