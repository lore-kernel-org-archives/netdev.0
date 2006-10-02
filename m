From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Introduce BROKEN_ON_64BIT facility
Date: Mon, 02 Oct 2006 17:21:11 +0100
Message-ID: <1159806071.8907.28.camel@localhost.localdomain>
References: <200610021352.k92DqRwa015220@cmf.nrl.navy.mil>
	 <1159801956.8907.13.camel@localhost.localdomain>
	 <20061002151853.GK16272@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: chas3@users.sourceforge.net, Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@osdl.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	kkeil@suse.de, kai.germaschewski@gmx.de,
	isdn4linux@listserv.isdn4linux.de, mac@melware.de,
	markus.lidel@shadowconnect.com, samuel@sortiz.org,
	Neela.Kolli@engenio.com, linux-scsi@vger.kernel.org,
	Greg KH <greg@kroah.com>, thomas@winischhofer.net, ak@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:51073 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP
	id S1750838AbWJBP5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 11:57:24 -0400
To: Matthew Wilcox <matthew@wil.cx>
In-Reply-To: <20061002151853.GK16272@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> (whitespace damaged; more for comment than for application).
> 
> > -        if ((u32)skb->data & 3) {
> > +        if ((unsigned long)skb->data & 3) {
> 
> I suppose it quietens a compiler warning.  Doesn't actually fix a bug
> though.

Right but it does no harm casting it to either so its worth cleaning up.

