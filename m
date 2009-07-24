From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: Jumbo frame question...
Date: Fri, 24 Jul 2009 11:41:55 -0400
Message-ID: <200907241141.55097.rgetz@blackfin.uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:52827 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757AbZGXPiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 11:38:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should a gigabit card, configured as 100, be sending jumbo UDP frames?

My understanding, is no - this is a spec violation..


Settings for eth0:
        Supported ports: [ MII ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Half 1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Half 1000baseT/Full
        Advertised auto-negotiation: Yes
        Speed: 100Mb/s
        Duplex: Half
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: g
        Wake-on: d
        Current message level: 0x000000ff (255)
        Link detected: no

happly sends UDP packets over 1500 bytes in length.

Tested with TFTP, and 2.6.27 (as the tftp server).

If tftp requests block sizes that are 4096 bytes, the sent packet is a single 
4096 byte packet (not multiple MTU sized packets).

?

Thanks
-Robin
