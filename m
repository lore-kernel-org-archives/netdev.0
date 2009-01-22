From: "Jorge Bastos" <mysql.jorge@decimal.pt>
Subject: sky2 hang with 2.6.28 and 2.6.29-rc2
Date: Thu, 22 Jan 2009 21:02:32 -0000 (WET)
Message-ID: <3876.87.196.10.75.1232658152.squirrel@webmail.decimal.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrly07.isp.novis.pt ([195.23.133.217]:60215 "EHLO
	mailrly07.isp.novis.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160AbZAVVBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 16:01:03 -0500
Received: from webmail.decimal.pt (localhost [127.0.0.1])
	by web.decimal.pt (Postfix) with ESMTP id 68084145BEE
	for <netdev@vger.kernel.org>; Thu, 22 Jan 2009 21:02:32 +0000 (WET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I've noticed with the kernel's (two different machines) 2.6.28 and
2.6.29-rc2, that the NIC's were hanging.

In the kernel output i have:
---
sky2 eth0: receiver hang detected
sky2 eth0: disabling interface
sky2 eth0: enabling interface
sky2 eth0: Link is up at 1000 Mbps, full duplex, flow control rx
---

the NIC is:
---
03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E
Gigabit Ethernet Controller (rev 15)
---

i've searched the web a bit and i saw some info that this seems to have
been fixed in arround 2.6.23 +/-, but still happening.



