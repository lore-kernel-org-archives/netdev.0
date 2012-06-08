From: Luigi Rizzo <rizzo@iet.unipi.it>
Subject: VALE, a Virtual Local Ethernet. http://info.iet.unipi.it/~luigi/vale/
Date: Fri, 8 Jun 2012 19:17:46 +0200
Message-ID: <20120608171746.GA30250@onelab2.iet.unipi.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from onelab2.iet.unipi.it ([131.114.59.238]:53007 "EHLO
	onelab2.iet.unipi.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760681Ab2FHQ7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 12:59:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have just completed a netmap extensions that let you build a
local high speed switch called VALE which i think can be very useful.

	http://info.iet.unipi.it/~luigi/vale/

VALE is a software Virtual Local Ethernet whose ports are accessible
using the netmap API. Designed to be used as the interconnect between
virtual machines (or as a fast local bus), it works as a learning
bridge and supports speeds of up to 20 Mpps with short frames, and
an aggregate 70 Gbit/s with 1514-byte packets. The VALE paper
contains more details and performance measurements.

VALE is implemented as a small extension of the netmap module, and
is available for FreeBSD and Linux. The source code includes a
backend for qemu and KVM, so you can use VALE to interconnect virtual
machines launching them with

	qemu -net nic -net netmap,ifname=vale0 ...
	qemu -net nic -net netmap,ifname=vale1 ...
	...

Processes can talk to a VALE switch too, so you can use the pkt-gen
or bridge tools that are part of the netmap distribution, or even
the pcap.c module that maps libpcap calls into netmap equivalents.
This lets you use VALE for all sort of pcap-based applications.

More details, code, bootable images on the VALE page,

	http://info.iet.unipi.it/~luigi/vale/

feedback welcome, as usual.

cheers
luigi
