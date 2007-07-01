From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] b44: power down PHY when interface down
Date: Sun, 1 Jul 2007 17:29:59 +0200
Message-ID: <200707011729.59673.mb@bu3sch.de>
References: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com> <200707011223.17235.mb@bu3sch.de> <20070701150006.GE7929@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: =?iso-8859-1?q?T=F6r=F6k_Edvin?= <edwintorok@gmail.com>,
	zambrano@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, power@bughost.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:57918
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbXGAPau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2007 11:30:50 -0400
In-Reply-To: <20070701150006.GE7929@xi.wantstofly.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 01 July 2007 17:00:06 Lennert Buytenhek wrote:
> On Sun, Jul 01, 2007 at 12:23:16PM +0200, Michael Buesch wrote:
> 
> > > More or less.  You can't add the resistances like that, since the
> > > bus isolation chip buffers the IDSEL signal, but it is correct that
> > > if the host's IDSEL resistor is larger than a certain value, the
> > > combination of the resistive coupling of IDSEL plus the extra buffer
> > > in the isolator might be causing the IDSEL input on the 'guest' PCI
> > > board to assert too late (or not assert at all), causing config
> > > accesses to fail.
> > > 
> > > (This also depends on the specific 'guest' PCI board used, as you
> > > noted, due to differing IDSEL trace lengths/capacitances and input
> > > pin capacitances on different PCI boards.  Also, it might work at
> > > 33 MHz but not work at 66 MHz, etc.)
> > 
> > It doesn't work on any of my boards :(
> 
> What extender board is this?  Do you have docs/schematics?

catalyst pcibx32
http://bu3sch.de/pcibx.php
Docs yes, schematics no.

> And what motherboard brand/type?

ABit AI7
The other was some MSI and some very old random board. dunno.
It works perfectly fine with other cards, like a linksys
wlan card with a broadcom 4318 chip. It's just the b44
that doesn't work in the extender.

> Actually, the IDSEL resistor would be on the computer's
> motherboard, not on the PCI board.  And to which address line

Yeah, I know.

> the IDSEL line is connected depends on which PCI slot on the
> motherboard you're looking at.

Sure.

> A multimeter should do the trick, but I would advise against this
> if you're not totally comfortable with hacking hardware.

Well, you mean to measure the idsel against each possible AD line?
It's difficult, because the motherboard is inside of a standard
computer case and a watercooling system is mounted. So I would
have to disassemble all that stuff. :/
Probably I can measure it with very thin probes on the slots
without unmounting the board, hm...

-- 
Greetings Michael.
