From: Ondrej Zajicek <santiago@crfreenet.org>
Subject: Re: [PATCH] via-rhine: suspend/resume bugfix
Date: Sun, 27 Apr 2008 11:58:44 +0200
Message-ID: <20080427095843.GA28784@localhost.localdomain>
References: <20080427071351.GA20561@localhost.localdomain> <4814406B.8000907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.crfreenet.org ([81.92.146.254]:36000 "EHLO
	mail.crfreenet.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753523AbYD0J6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 05:58:46 -0400
Content-Disposition: inline
In-Reply-To: <4814406B.8000907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 27, 2008 at 10:59:23AM +0200, Jiri Slaby wrote:
> >+	/* Disable interrupts by clearing the interrupt mask. */
> >+	iowrite16(0x0000, ioaddr + IntrEnable);
> >+
> >+	/* Stop the chip's Tx and Rx processes. */
> >+	iowrite16(CmdStop, ioaddr + ChipCmd);

> What about PCI posting?

Hmm, i will fix it. And i found that the patch might break
wakeup-on-LAN. So please discard it.

-- 
Elen sila lumenn' omentielvo

Ondrej 'SanTiago' Zajicek (email: santiago@crfreenet.org)
OpenPGP encrypted e-mails preferred (KeyID 0x11DEADC3, wwwkeys.pgp.net)
"To err is human -- to blame it on a computer is even more so."
