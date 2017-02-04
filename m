From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: Add watchdog interrupt
 handler
Date: Sun, 5 Feb 2017 00:31:40 +0100
Message-ID: <20170204233140.GB13323@lunn.ch>
References: <1486240734-13157-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55902 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750955AbdBDXbp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 4 Feb 2017 18:31:45 -0500
Content-Disposition: inline
In-Reply-To: <1486240734-13157-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 04, 2017 at 09:38:54PM +0100, Andrew Lunn wrote:
> The switch contains a watchdog looking for issues with the internal
> gubbins of the switch. Hook the interrupt the watchdog triggers and
> log the value of the control register indicating why the watchdog
> fired. The watchdog can only be cleared with a switch reset, which
> will destroy the current configuration. Rather than doing this, just
> disable the interrupt.

Arg!

It has been pointed out that the mv88e6390 does watchdogs differently,
and this code is not going to work there.

Please drop this patch, i will post a new version later.

       Andrew
