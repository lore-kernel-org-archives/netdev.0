From: David Miller <davem@davemloft.net>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Mon, 07 Jul 2008 14:58:19 -0700 (PDT)
Message-ID: <20080707.145819.209342070.davem@davemloft.net>
References: <20080707214218.055bcb35@the-village.bc.nu>
	<20080707.144505.67398603.davem@davemloft.net>
	<20080707221427.163c4a30@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, dwmw2@infradead.org, andi@firstfloor.org,
	tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org,
	kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55412
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758876AbYGGV6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 17:58:19 -0400
In-Reply-To: <20080707221427.163c4a30@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Mon, 7 Jul 2008 22:14:27 +0100

> > > You seem to be trying to conflate legal and technical issues here.
> > 
> > Exactly like the patches we are current discussing.
> > 
> > Thanks for walking right into that. :-)
> 
> No - the patches are for technical reasons, 

Which are?  Consistent use of request_firmware()?

That's pure bullox as far as I can see.  Why provide the means to
do something nobody has had a need for in 6+ years?  Who needs
to load different firmware for the tg3 driver?

Who needs that capability? Distribution vendors?  What for?
In what case will they need to load different firmware from
what the driver maintainer tested as a unit?

Rather, they want separation.  I can see no other real impetus.

And, btw, who has the right to enforce this new burdon upon driver
maintainers when they have had a working and maintainable system for
so long?

I can only see it being about separation, pure and simple.
