From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: Strange uses of netif_start_queue
Date: Fri, 12 Aug 2005 14:39:05 +0100
Message-ID: <20050812133905.GF2819@linux-mips.org>
References: <1123853714.22460.39.camel@localhost.localdomain> <20050812132758.GE2819@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Content-Disposition: inline
In-Reply-To: <20050812132758.GE2819@linux-mips.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Aug 12, 2005 at 02:27:59PM +0100, Ralf Baechle wrote:

> > Something I noticed doing the tty work. the 6pack driver calls
> > netif_start_queue() before it calls register_netdev. I'm curious if this
> > is allowed ?
> 
> As part of adding support for extended 6pack which is required by the
> PR 430 I've recently fixed that.  It was looking suspect enough that I
> fixed it though I don't see any way this could do harm.

To answer the fundamental question, I think netif_start_queue /
netif_stop_queue should be allowed in case the driver for some reason has
the desire to stop queueing of packet immediately after register_netdev.

  Ralf
