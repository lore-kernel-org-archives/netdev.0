From: Celejar <celejar@gmail.com>
Subject: bleeding edge kernels misidentify my Broadcom BCM4401-B0
Date: Wed, 9 Feb 2011 15:58:41 -0500
Message-ID: <20110209155841.7a8c6892.celejar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:61504 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752287Ab1BIU6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 15:58:44 -0500
Received: by vws16 with SMTP id 16so384372vws.19
        for <netdev@vger.kernel.org>; Wed, 09 Feb 2011 12:58:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Recently, while using bleeding edge kernels (built from git pulls of
vanillas sources from kernel.org), my Broadcom BCM4401-B0 Ethernet
card, normally driven by the b44 driver, has stopped working.  Poking
around, I discovered that the card is no longer correctly identified;
it now shows up (with 'lspci -v' as root) as this bizarre device:

06:01.0 Network and computing encryption device: Broadcom Corporation Device 0010 (rev 02) (prog-if 10)
        Subsystem: Allied Telesis, Inc Device 0010
        Flags: fast devsel, IRQ 10
        Memory at d0000000 (32-bit, non-prefetchable) [disabled] [size=8K]
        Capabilities: [40] Power Management version 2

Using a stock Debian kernel (2.6.32-5-686), it shows up (and works)
correctly:

06:01.0 Ethernet controller: Broadcom Corporation BCM4401-B0 100Base-TX (rev 02)
        Subsystem: Acer Incorporated [ALI] Device 0090
        Flags: bus master, fast devsel, latency 64, IRQ 21
        Memory at d0000000 (32-bit, non-prefetchable) [size=8K]
        Capabilities: [40] Power Management version 2
        Kernel driver in use: b44

What on earth is this all about?

I tried another kernel I had lying around,
2.6.37-rc6-lizzie-00132-g55ec86f (built from kernel.org vanilla
sources), and it also works fine.  I can do a bisection if necessary,
but I figured I'd check here first.

[Please cc. me on replies.]

Celejar
-- 
foffl.sourceforge.net - Feeds OFFLine, an offline RSS/Atom aggregator
mailmin.sourceforge.net - remote access via secure (OpenPGP) email
ssuds.sourceforge.net - A Simple Sudoku Solver and Generator

