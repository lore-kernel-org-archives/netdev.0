From: Chris Adams <cmadams@hiwaay.net>
Subject: Problem with Compaq NC3131 dual eth card
Date: Tue, 6 Jan 2004 09:17:51 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040106151751.GB1509622@hiwaay.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have a Compaq NC3131 dual 10/100 ethernet PCI (64/32 bit in a 32 bit
slot) card.  The e100 module doesn't work, and the eepro100 module can
be coerced to work but complains about it (this is with Fedora Core 1
and kernel-2.4.22-1.2135.nptl.athlon.rpm).

The e100 module prints:

************************************************************************
Intel(R) PRO/100 Network Driver - version 2.3.18-k1
Copyright (c) 2003 Intel Corporation

divert: allocating divert_blk for eth1
e100: selftest OK.
e100: Invalid Ethernet address
e100: Failed to initialize, instance #0
divert: freeing divert_blk for eth1
divert: allocating divert_blk for eth1
e100: selftest OK.
e100: Invalid Ethernet address
e100: Failed to initialize, instance #0
divert: freeing divert_blk for eth1
************************************************************************

and unloads itself immediately.  The eepro100 module prints:

************************************************************************
eepro100.c:v1.09j-t 9/29/99 Donald Becker http://www.scyld.com/network/eepro100.html
eepro100.c: $Revision: 1.36 $ 2000/11/17 Modified by Andrey V. Savochkin <saw@saw.sw.com.sg> and others
divert: allocating divert_blk for eth1
eth1: Invalid EEPROM checksum 0xffc0, check settings before activating this device!
eth1: OEM i82557/i82558 10/100 Ethernet, FF:FF:FF:FF:FF:FF, IRQ 11.
  Board assembly ffffff-255, Physical connectors present: RJ45 BNC AUI MII
  Primary interface chip unknown-15 PHY #31.
    Secondary interface chip i82555.
  General self-test: passed.
  Serial sub-system self-test: passed.
  Internal registers self-test: passed.
  ROM checksum self-test: passed (0x24c9f043).
divert: allocating divert_blk for eth2
eth2: Invalid EEPROM checksum 0xffc0, check settings before activating this device!
eth2: OEM i82557/i82558 10/100 Ethernet, FF:FF:FF:FF:FF:FF, IRQ 10.
  Board assembly ffffff-255, Physical connectors present: RJ45 BNC AUI MII
  Primary interface chip unknown-15 PHY #31.
    Secondary interface chip i82555.
  General self-test: passed.
  Serial sub-system self-test: passed.
  Internal registers self-test: passed.
  ROM checksum self-test: passed (0x24c9f043).
************************************************************************

It will load and let me configure the devices.  If I force it to a
different MAC address (reusing the MAC from eth0 and moving the wire to
avoid ARP problems), it seems to work, but I shouldn't have to do that.

Is my card defective or is this a compatibility problem?  Is there a way
to fix this?
-- 
Chris Adams <cmadams@hiwaay.net>
Systems and Network Administrator - HiWAAY Internet Services
I don't speak for anybody but myself - that's enough trouble.
