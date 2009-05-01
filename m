From: Florian Fainelli <florian@openwrt.org>
Subject: tulip_rxtx_stop() on Cobalt Qube2
Date: Fri, 1 May 2009 12:38:57 +0200
Message-ID: <200905011238.59345.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, grundler@parisc-linux.org, kyle@mcmartin.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:34464 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754402AbZEAKjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 06:39:06 -0400
Received: by ewy24 with SMTP id 24so2379171ewy.37
        for <netdev@vger.kernel.org>; Fri, 01 May 2009 03:39:05 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Grant, Kyle,

I just updated my Qube2 to run a 2.6.30-rc2-00476-gd678033 kernel (also seen 
on a 2.6.29-rc2-00462-gfa04b54) and I get the following message while booting 
the box now, I have not git bisected the offending commit yet :

[snip]
Linux Tulip driver version 1.1.15-NAPI (Feb 27, 2007)
PCI: Enabling device 0000:00:07.0 (0045 -> 0047)
tulip0: Old format EEPROM on 'Cobalt Microserver' board.  Using substitute 
media control info.
tulip0:  EEPROM default media type Autosense.
tulip0:  Index #0 - Media MII (#11) described by a 21142 MII PHY (3) block.
tulip0:  MII transceiver #1 config 1000 status 7809 advertising 01e1.
eth0: Digital DS21142/43 Tulip rev 65 at MMIO 0x12082000, 00:10:e0:00:7d:1f, 
IRQ 19.
PCI: Enabling device 0000:00:0c.0 (0005 -> 0007)
tulip1: Old format EEPROM on 'Cobalt Microserver' board.  Using substitute 
media control info.
tulip1:  EEPROM default media type Autosense.
tulip1:  Index #0 - Media MII (#11) described by a 21142 MII PHY (3) block.
tulip1:  MII transceiver #1 config 1000 status 7809 advertising 01e1.
eth1: Digital DS21142/43 Tulip rev 65 at MMIO 0x12082400, 00:10:e0:00:88:b9, 
IRQ 20.
[snip]
0000:00:07.0: tulip_stop_rxtx() failed (CSR5 0xf0660000 CSR6 0xb20e2202)
eth0: Setting full-duplex based on MII#1 link partner capability of 45e1.

The interface is still fully functional, shall we increase the timeount in 
tulip_stop_rxtx() to prevent this message from appearing ?

Thanks a lot in advance for your answer.
-- 
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------
