From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [RFC] FEC patches
Date: Wed, 14 Jan 2009 17:09:07 +0100
Message-ID: <1231949353-29630-1-git-send-email-s.hauer@pengutronix.de>
Cc: Sebastian Siewior <bigeasy@linutronix.de>,
	Greg Ungerer <gerg@uclinux.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56948 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129AbZANQJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 11:09:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The following patches apply to the FEC driver (drivers/net/fec.c). While
found on several Freescale/Motorola chips, this driver is currently only
used for Coldfire. These patches add support for the ARM based i.MX27
SoC.

I'm almost sure I break the driver for some (all?) Coldfire guys, but I
do not have any Coldfire based board to test the patches on.

The first 4 patches should be ok as is, comments?
The other patches are somewhat work in progress, but they show which
changes I need for my hardware.

The driver could use quite some cleanup patches for coding style, turn
it into a platform device driver and add exit functions. I'm sure I
could find some time to work on these topics, but first I need the
patches to support my board to be able to test my changes.

Any comments welcome

Sascha

PS Greg, Sebastian: I'm sending this again because I got the list
address wrong. I put you on cc because you were the last persons
committing patches to this driver


