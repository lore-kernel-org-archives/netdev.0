From: Jonathan Thibault <jonathan@navigue.com>
Subject: Bonding/LACP on RTL8169sc/8110sc (R1869)
Date: Tue, 12 Apr 2011 09:35:20 -0400
Message-ID: <4DA45518.60407@navigue.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.navigue.com ([74.117.40.3]:45409 "EHLO mail.navigue.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754503Ab1DLNni (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 09:43:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings all,

I have a a pair of Jetway motherboards with an add-on 3Gbit LAN modules
and have been doing some testing for a linux router project.  I found
that I while I can get LACP working properly using eth0 and eth1, using
the exact same setup with any of the other three lan fails.  Is this a
known issue?

This is on Linux 2.6.32.10.  Here is a blurb of dmesg showing the NICs
detected.

eth0: RTL8168b/8111b at 0xf8adc000, 00:30:18:ac:a6:80, XID 0c200000 IRQ 24
eth1: RTL8168b/8111b at 0xf8ae0000, 00:30:18:ac:a6:81, XID 0c200000 IRQ 25
eth2: RTL8169sc/8110sc at 0xf8ae4c00, 00:30:18:ae:34:3a, XID 18000000 IRQ 18
eth3: RTL8169sc/8110sc at 0xf8ae8800, 00:30:18:ae:34:3b, XID 18000000 IRQ 19
eth4: RTL8169sc/8110sc at 0xf8aec400, 00:30:18:ae:34:3c, XID 18000000 IRQ 16

I can probably manage this project using only eth0 and eth1 in LACP
configuration but I figured I'd give a heads up.

The interfaces seem able to detect when the link is up or down, bonding
removes and adds them to the LACP trunk but I can't get traffic through
them.

Kind regards,

Jonathan
