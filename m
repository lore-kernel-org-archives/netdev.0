From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 30/31] CAPI: Remove experimental tag from middleware
 feature
Date: Sat, 23 Jan 2010 13:56:27 +0000
Message-ID: <20100123135627.23b2f9e0@lxorguk.ukuu.org.uk>
References: <cover.1264201406.git.jan.kiszka@web.de>
	<9dd553d458def04edc7790f0320ffdf1f8909aa5.1264201408.git.jan.kiszka@web.de>
	<20100123122327.7d2622f4@lxorguk.ukuu.org.uk>
	<4B5AF60B.3070100@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: Jan Kiszka <jan.kiszka@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:59630 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755295Ab0AWNyY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 08:54:24 -0500
In-Reply-To: <4B5AF60B.3070100@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 23 Jan 2010 14:13:47 +0100
Jan Kiszka <jan.kiszka@web.de> wrote:

> Alan Cox wrote:
> > On Sun, 10 Jan 2010 14:12:41 +0100
> > Jan Kiszka <jan.kiszka@web.de> wrote:
> > 
> >> Despite all its bugs, the middleware support of our CAPI stack was
> >> already in use for many, many moons. And after going through its code,
> >> fixing all issues I found, I feel it deserves to officially become a
> >> non-experimental feature.
> > 
> > Slightly NAK this - I'm really glad to see the work getting done, but
> > until it uses krefs properly for the tty references I'd say it is
> > experimental still.
> > 
> > I'd like to help you sort out the tty krefs stuff, using tty_port and so
> > on and get that wart fixed too.
> 
> Will look into to this. Some good starting point or reference driver for me?

Most of the drivers at least use tty_port and the tty_port ref counting
helpers. The most full use of the new interfaces is probably the latest
USB serial code and the drivers/mmc/card/sdio_uart.c code, which uses all
the new facilities to the full to kick all the nasty open/close/hangup
locking and logic out of the low level drivers.

