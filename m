From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6] natsemi.c NAPI
Date: Mon, 20 Sep 2004 15:07:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920190746.GA17210@havoc.gtf.org>
References: <20040920141030.GV1307@sunbeam.de.gnumonks.org> <20040920115746.7ccbfb45.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harald Welte <laforge@gnumonks.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040920115746.7ccbfb45.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 20, 2004 at 11:57:46AM -0700, David S. Miller wrote:
> This driver (before the NAPI patch) is a bit buggy, it does
> no RX processing SMP locking.  So if one one cpu you're doing
> RX interrupt processing, and on another cpu tx_timeout() runs
> we're totally screwed.

RX processing in current natsemi only happens in irq, and the natsemi
driver properly disables irqs when it needs to, AFAICS, using
enable/disable_irq().

	Jeff
