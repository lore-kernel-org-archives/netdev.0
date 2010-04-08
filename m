From: Matthias Kaehlcke <matthias@kaehlcke.net>
Subject: FEC driver: rcv is not +last
Date: Thu, 8 Apr 2010 12:40:33 +0200
Message-ID: <20100408104033.GI3787@darwin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow3-v.mail.gandi.net ([217.70.178.89]:49694 "EHLO
	slow3-v.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755212Ab0DHKmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 06:42:49 -0400
Received: from relay1-v.mail.gandi.net (relay1-v.mail.gandi.net [217.70.178.75])
	by slow3-v.mail.gandi.net (Postfix) with ESMTP id 7C8A239A2A
	for <netdev@vger.kernel.org>; Thu,  8 Apr 2010 12:42:46 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

i have problems with the FEC on a i.MX25 3-Stack board. the kernel is
v2.6.34-rc2 plus the following patch:
http://patchwork.ozlabs.org/patch/41235/

the following traces are generated at boot time:

FEC Ethernet Driver
fec: PHY @ 0x1, ID 0x20005ce1 -- unknown PHY!
...
eth0: config: auto-negotiation on, 100FDX, 100HDX, 10FDX, 10HDX.
...
FEC ENET: rcv is not +last
FEC ENET: rcv is not +last
FEC ENET: rcv is not +last
FEC ENET: rcv is not +last
...

the PHY of the board is a DP83840, which is not supported by the
driver. could this be the problem? i tried to make the kernel think
the DP83840 is a DP83848, which is supported, but the behaviour is the
same except the 'unknown PHY' warning.

any idea what could be wrong?

-- 
Matthias Kaehlcke
Embedded Linux Developer
Barcelona

              You can't separate peace from freedom because no
               one can be at peace unless he has his freedom
                              (Malcolm X)
                                                                 .''`.
    using free software / Debian GNU/Linux | http://debian.org  : :'  :
                                                                `. `'`
gpg --keyserver pgp.mit.edu --recv-keys 47D8E5D4                  `-
