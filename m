From: Dave Jones <davej@redhat.com>
Subject: 2.6.21rc7 e1000 media-detect oddness.
Date: Sun, 15 Apr 2007 23:45:39 -0400
Message-ID: <20070416034539.GC21217@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51469 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754427AbXDPDpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Apr 2007 23:45:42 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3G3jeSF003997
	for <netdev@vger.kernel.org>; Sun, 15 Apr 2007 23:45:41 -0400
Received: from gelk.kernelslacker.org (vpn-248-7.boston.redhat.com [10.13.248.7])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3G3jews025187
	for <netdev@vger.kernel.org>; Sun, 15 Apr 2007 23:45:40 -0400
Received: from gelk.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by gelk.kernelslacker.org (8.13.8/8.13.8) with ESMTP id l3G3je6i002055
	for <netdev@vger.kernel.org>; Sun, 15 Apr 2007 23:45:40 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.13.8/8.13.8/Submit) id l3G3jdue002054
	for netdev@vger.kernel.org; Sun, 15 Apr 2007 23:45:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I booted up 2.6.21rc7 without an ethernet cable plugged in,
and noticed this..

e1000: 0000:02:00.0: e1000_probe: The EEPROM Checksum Is Not Valid
e1000: probe of 0000:02:00.0 failed with error -5

I plugged a cable in, did rmmod e1000;modprobe e1000, and got this..

e1000: 0000:02:00.0: e1000_probe: (PCI Express:2.5Gb/s:Width x1) 00:16:d3:3a:62:d3
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex, Flow Control: RX
e1000: eth0: e1000_watchdog: 10/100 speed: disabling TSO

and it works fine..
Why would no cable make it think the EEPROM is invalid ?

I repeated this a few times, just to be sure it wasn't a fluke, and it
seems to happen 100% reproducably.

	Dave

-- 
http://www.codemonkey.org.uk
