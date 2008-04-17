From: Lucas Nussbaum <lucas.nussbaum@imag.fr>
Subject: Wake on LAN doesn't work with r8169
Date: Thu, 17 Apr 2008 18:37:21 +0200
Message-ID: <20080417163721.GA2442@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([80.248.208.235]:39393 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757740AbYDQRME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2008 13:12:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to get Wake on LAN to work with this device:
01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 01)

If I run "ifconfig eth0 down", or let my shutdown scripts put down the
interface, WOL won't work.
If I modify my shutdown script to leave the interface up, WOL works.
This is inconvenient, because most cards have the opposite behaviour
(WOL usually works when the interface is put down).

Since the driver explicitely mentions WOL in the suspend/resume code, I
tried that too, but couldn't get the system to wake up using WOL. (has
this been confirmed to work?)

The r8168 driver from Realtek has the same behaviour.

Any clues?

Thank you,
-- 
| Lucas Nussbaum                        PhD student |
| lucas.nussbaum@imag.fr        LIG / Projet MESCAL |
| jabber: lucas@nussbaum.fr    +33 (0)6 64 71 41 65 |
| homepage:        http://www-id.imag.fr/~nussbaum/ |
