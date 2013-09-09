From: =?UTF-8?B?RMOibmllbA==?= Fraga <fragabr@gmail.com>
Subject: e1000e: link up and down issue with TP-Link WDR4300 router
Date: Sun, 8 Sep 2013 21:33:31 -0300
Message-ID: <l0j50m$2ii$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:37865 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885Ab3IIAdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Sep 2013 20:33:47 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VIpQG-0007ex-Oy
	for netdev@vger.kernel.org; Mon, 09 Sep 2013 02:33:44 +0200
Received: from 177.189.67.96 ([177.189.67.96])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 09 Sep 2013 02:33:44 +0200
Received: from fragabr by 177.189.67.96 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 09 Sep 2013 02:33:44 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Since I bought this motherboard (Asus P8Z68V-Pro Gen/3) I have
to deal sometimes (very rare) with this annoying problem:

Sep  8 21:24:43 tux kernel: e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: Rx/Tx
Sep  8 21:24:43 tux kernel: e1000e 0000:00:19.0 eth0: 10/100 speed: disabling TSO
Sep  8 21:24:44 tux kernel: e1000e: eth0 NIC Link is Down

	It keeps trying to establish the link forever, going up and down.

	Today it happened after I resumed from standby (S3).

	My NIC is:

00:19.0 Ethernet controller: Intel Corporation 82579V Gigabit Network
Connection (rev 05)

	If I search in google for "e1000e link up down" I see a LOT of users complaining.
As far as I remember Alan Cox onde wrote this is a issue with "cheap chinese router"
but I don't understand why there isn't a workaround for this annoying problem.

	Usually it establishes the link at 1000 Mbps and as long as I don't turn off the router, 
it negotiates the link speed correctly.

	Is there some workaround for this? If you need more information, just ask!

	Thanks.

	Ps: I'm using Linux 3.11.0.

-- 
Linux 3.11.0: Linux for Workgroups
http://www.youtube.com/DanielFragaBR
http://www.libertarios.org.br
