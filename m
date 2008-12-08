From: Jan Rekorajski <baggins@sith.mimuw.edu.pl>
Subject: Re: Nasty regression from .27.7 to .27.8: idle samba goes crazy
Date: Mon, 8 Dec 2008 23:22:46 +0100
Message-ID: <20081208222246.GA29232@sith.mimuw.edu.pl>
References: <pan.2008.12.08.06.18.57.357875@wizards.de> <200812080834.22924.rjw@sisk.pl> <pan.2008.12.08.08.07.29.439625@wizards.de> <493D4F5C.7020606@s5r6.in-berlin.de> <493D7349.10200@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Holger Hoffstaette <holger@wizards.de>, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Greg KH <greg@kroah.com>,
	stable@kernel.org, Stefan Richter <stefanr@s5r6.in-berlin.de>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sith.mimuw.edu.pl ([193.0.96.4]:26619 "EHLO sith.mimuw.edu.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754081AbYLHWah (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2008 17:30:37 -0500
Content-Disposition: inline
In-Reply-To: <493D7349.10200@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 08 Dec 2008, Stefan Richter wrote:

> >>> On Monday, 8 of December 2008, Holger Hoffstaette wrote:
> >>>> The system is a generic old single-core P4 box with a single SATA drive,
> >>>> Gentoo userland and Samba is 3.0.33 (in async mode). The kernel has no
> >>>> patches or binary drivers.
> 
> Holger, it may be unrelated to the issue, but to be sure:  Which network
> card driver do you use?

I think you can safely rule out NIC, I'm also seeing this behaviour on a
brand new server with imap hanging in some busy-loop.
Network card in my case:
Broadcom Corporation NetXtreme II BCM5708 Gigabit Ethernet (rev 12)

What I observer was one CPU doing 100% system work, and the number of
timer interrupts went from 1k per second to 4k (for the whole system).

I didn't report it because I thought it's one of patches I have to blame.
Oh, and, unfortunately, I can't bisect, I'm seeing this only on one machine
that has to be running.

Jan
-- 
Jan Rekorajski            |  ALL SUSPECTS ARE GUILTY. PERIOD!
baggins<at>mimuw.edu.pl   |  OTHERWISE THEY WOULDN'T BE SUSPECTS, WOULD THEY?
BOFH, MANIAC              |                   -- TROOPS by Kevin Rubio
