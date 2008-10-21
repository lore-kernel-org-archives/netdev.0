From: Robert Olsson <robert@robur.slu.se>
Subject: slab/slub
Date: Tue, 21 Oct 2008 10:45:02 +0200
Message-ID: <18685.38542.458998.963572@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:47616 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751011AbYJUIpF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 04:45:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Stephen, 

We discussed slab vs slub sometime ago. In a very simple forwarding test 
using one CPU-core:

SLAB ~1.0 Mpps
SLUB ~1.0 Mpps

Cheers.
						--ro


ixgbe multiQ driver 64 byte pkts
Linux version 2.6.27-rc2bifrost-11946-g6ced0b3-dirty (root@gatling) (gcc version 4.2.2) #10 SMP Wed Aug 13 22:16:13 CEST 2008

SLAB

eth0 input 2.30 Mpps

Iface   MTU Met   RX-OK RX-ERR RX-DRP RX-OVR   TX-OK TX-ERR TX-DRP TX-OVR Flg
eth0   1500   0 4457671      0 5542329      0       6      0      0      0 BMRU
eth1   1500   0       1      0      0      0 4456529      0      0      0 BMRU


softnet_stat
00000008 00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
004404c8 00880094 0000417c 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000

------------------------------------------------------------------------------
SLUB

eth0 input 2.34 Mpps

Iface   MTU Met   RX-OK RX-ERR RX-DRP RX-OVR   TX-OK TX-ERR TX-DRP TX-OVR Flg
eth0   1500   0 4274583      0 5725417      0       6      0      0      0 BMRU
eth1   1500   0       1      0      0      0 4273633      0      0      0 BMRU

softnet_stat
00000008 00000001 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
00413998 00826bb4 00003b7c 00000000 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
