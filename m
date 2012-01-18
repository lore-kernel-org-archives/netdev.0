From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: ixgbe: Unsupported SFP+ modules on 10Gbit/s X520-DA2 NIC?
Date: Wed, 18 Jan 2012 12:30:58 +0100
Message-ID: <1326886258.19261.25.camel@probook>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: e1000-devel@lists.sourceforge.net,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:57336 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756683Ab2ARLkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 06:40:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Intel,

I just bought three 10Gbit/s X520-DA2 NICs (82599 based) for
production usage, but I cannot get them to accept any of my 10Gbit/s
SFP+ modules (4 different tried). According to the documentation I can
find, the X520-DA2 NIC should support fiber optics SFP+ modules.

The SFP+ modules does work in another 82599 based NIC in the same
machine (engineering sample from PJ).

According to the driver code (ixgbe) the 82599 and the X520 looks like
they share the same init code.

What is going on with the X520-DA2 model?


Extra info below:

Tested with:
 Kernel: 3.2.0-net-next-14778-g117ff42
 (ethtool -i)
 driver: ixgbe
 version: 3.6.7-k
 firmware-version: 0x18f60001
 bus-info: 0000:24:00.0

The working NIC reports firmware-version: 0xd87c0000.

The kern.log error:
 ixgbe 0000:24:00.1: failed to load because an unsupported SFP+ module type was detected.
 ixgbe 0000:24:00.1: Reload the driver after installing a supported module.

The PCI vendor ID's are also almost the same between the two cards:
 # None working X520-DA2 NIC
 lspci -n | grep 24:00.
 24:00.0 0200: 8086:10fb (rev 01)
 24:00.1 0200: 8086:10fb (rev 01)
 # Working NIC
 lspci -n | grep 12:00.
 12:00.0 0200: 8086:10fb
 12:00.1 0200: 8086:10fb

-- 
Best regards,
  Jesper Dangaard Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
