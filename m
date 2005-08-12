From: Patrick McHardy <kaber@trash.net>
Subject: Re: Strange uses of netif_start_queue
Date: Fri, 12 Aug 2005 15:33:41 +0200
Message-ID: <42FCA535.3090108@trash.net>
References: <1123853714.22460.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1123853714.22460.39.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
> Something I noticed doing the tty work. the 6pack driver calls
> netif_start_queue() before it calls register_netdev. I'm curious if this
> is allowed ?

All netif_start_queue does is clear_bit(...), so it is a NOP at that
point. I guess it could be removed.
