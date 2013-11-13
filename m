From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: how to mix bridges and bonding inc. vlans correctly on Kernel > 3.10
Date: Wed, 13 Nov 2013 14:58:40 +0100
Message-ID: <52838590.5070806@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ph.de-nserver.de ([85.158.179.214]:53532 "EHLO
	mail-ph.de-nserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757288Ab3KMN6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 08:58:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

while my vlans, bridging and bonding stuff was working until 3.9 i never
thought about how it is right. So maybe i was always wrong.

I've this:

eth2
     \
      -- bond1 -- vmbr1
     /
eth3

This works fine and as expected now i want to have a vlan using the
bonding and using a bridge.

I the past i had this:
eth2
     \
      -- bond1 -- vmbr1
     /              \
eth3                 \ vmbr1.3000
                           \ ---- tap114i1

This was working fine until 3.9.X since 3.10. Right now using 3.10 i
need to put eth2 and eth3 into promisc mode to get it working ;-( this
is bad!

I also tried this one without success:
eth2
     \
      -- bond1 -- vmbr1
     /     \
eth3        ----- bond1.3000 --- vmbr1v3000
                                     \ ---- tap114i1



Greets,
Stefan
