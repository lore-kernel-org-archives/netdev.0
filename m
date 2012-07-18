From: "J. Christopher Pereira" <kripper@imatronix.cl>
Subject: r8169: link up, link down
Date: Wed, 18 Jul 2012 11:21:52 -0400
Message-ID: <02b401cd64f9$115acc90$341065b0$@cl>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from abufalia.dnsforhost.com ([67.220.212.159]:54045 "EHLO
	abufalia.dnsforhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754676Ab2GRPWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 11:22:05 -0400
Received: from pc-75-127-215-201.cm.vtr.net ([201.215.127.75]:63002 helo=Toshi)
	by abufalia.dnsforhost.com with esmtpa (Exim 4.77)
	(envelope-from <kripper@imatronix.cl>)
	id 1SrW4d-0000z2-FA
	for netdev@vger.kernel.org; Wed, 18 Jul 2012 10:22:02 -0500
Content-Language: es
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

An old FC11 server died recently so we changed the hardware.
The new hardware has a r8169 nic with the following driver version (dmesg
output):

        r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
        r8169 0000:02:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
        r8169 0000:02:01.0: no PCI Express capability

Once in a while, the nic stops working with many "link up" and "link down"
messages:

        r8169: eth1: link up
        r8169: eth1: link down

The problem is solved by reseting the server.

I found some bug reports out there, but couldn't find any clear info about
the problem or if it has been fixed in newer driver versions.
The server is using the latest FC11 kernel
(kernel-2.6.30.10-105.2.23.fc11.x86_64) and FC11 reached its end of life.
Replacing the nic for another model is obviously the simplest solution, but.

Is there any solution or workarround?
