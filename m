From: Luigi Rizzo <rizzo@iet.unipi.it>
Subject: netmap for linux now available
Date: Tue, 13 Mar 2012 00:08:09 +0100
Message-ID: <20120312230809.GA45615@onelab2.iet.unipi.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from onelab2.iet.unipi.it ([131.114.59.238]:57273 "EHLO
	onelab2.iet.unipi.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757693Ab2CLW4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 18:56:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

just in case you might be interested...

i have recently completed a linux port of the netmap framework.
Code, documentation and PicoBSD/Tinycore bootable images are at

	http://info.iet.unipi.it/~luigi/netmap/

Netmap is a device-independent framework for packet generation and
capture from user space; it can do line rate at 10Gbit/s (14.88Mpps)
with just one core at about 1GHz.

Netmap relies on a kernel module (netmap_lin.ko) and slightly
modified device drivers (about 4-500 lines per driver).  It requires
no kernel patches apart from device drivers (and abusing the ax25
field in struct netdevice).
Userspace programs can use the native API (documented in netmap.4)
or a libpcap emulation library. It has been integrated in FreeBSD
last fall, and the linux version uses mostly the same code plus a bit
of glue to adapt the BSD<->linux kernel ABI.

The current version supporting the ixgbe and e1000/e1000e driver.
Patches for other devices (igb, r8169, forcedeth) are avaiable but
untested.

	cheers
	luigi
