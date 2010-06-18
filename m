From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Distributed Switch Architecture(DSA)
Date: Fri, 18 Jun 2010 09:06:52 +0200
Message-ID: <OF4DC5B7A3.2D318B4E-ONC1257746.00253DA6-C1257746.002714B0@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:52104 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753696Ab0FRHJO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jun 2010 03:09:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I am trying to wrap my head around DSA and I need some help.

Assume the example from Lennert:

		 +-----------+       +-----------+
		 |           | RGMII |           |
		 |           +-------+           +------ 1000baseT MDI ("WAN")
		 |           |       |  6-port   +------ 1000baseT MDI ("LAN1")
		 |    CPU    |       |  ethernet +------ 1000baseT MDI ("LAN2")
		 |           |MIImgmt|  switch   +------ 1000baseT MDI ("LAN3")
		 |           +-------+  w/5 PHYs +------ 1000baseT MDI ("LAN4")
		 |           |       |           |
		 +-----------+       +-----------+

If I understand this correctly I get at least 5 virtual I/Fs corresponding
to WAN, LAN1-4, but how is the RGMII I/F modelled?
I guess I will have one "real" ethX I/F which maps to RGMII but do I get one
virtual I/F too?
What use are these virtual I/Fs? Just to read status from the corresponding
ports? Can one TX and RX network pkgs over these I/Fs too?

Now I want to add STP/RSTP to the switch. How would one do that?

 Jocke

