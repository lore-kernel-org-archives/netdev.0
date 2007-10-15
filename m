From: Willy Tarreau <w@1wt.eu>
Subject: FWD: 2.4.35 e1000 problems
Date: Mon, 15 Oct 2007 15:59:17 +0200
Message-ID: <20071015135917.GA9608@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, dmpesl <dmpesl@ldis.cs.msu.su>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:3119 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758347AbXJOOBe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 10:01:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Dmitry, I've forwarded your mail to the netdev mailing list and to
the e1000 maintainers.

Auke, does it sound like a known problem ? Maybe someone has seen it
in 2.6 ? Just for the record, e1000 in 2.4.35 is 7.3.20-k4.

Dmitry, if you have time for a test, I think it would be good if you
could test the most recent driver from e1000.sf.net. It might give
us some more information about the problem's cause. Otherwise, let's
wait for Auke's advices and/or questions.

Regards,
Willy

----- Forwarded message from dmpesl <dmpesl@ldis.cs.msu.su> -----

Date: Mon, 15 Oct 2007 17:54:01 +0400 (MSD)
From: dmpesl <dmpesl@ldis.cs.msu.su>
Subject: 2.4.35 e1000 problems
To: w@1wt.eu
X-X-Sender: dmpesl@ldisi.cs.msu.su

Hello, Willy

on recent month i've changed kernel from 2.4.31->2.4.35 on my Owl-based 
web server (purchased SATA hdd, onboard SATA 20378), Asus PCH-DR mb, 
2*Xeon, and noticed that following error occurs on network card:
---------------------------------------------
Sep 29 21:29:51 host kernel: NETDEV WATCHDOG: eth0: transmit timed out
Sep 29 21:29:53 host kernel: e1000: eth0: e1000_watchdog: NIC Link is Up 
100 Mbps Full Duplex, Flow Control: RX/TX
Sep 29 22:28:03 host kernel: NETDEV WATCHDOG: eth0: transmit timed out
Sep 29 22:28:05 host kernel: e1000: eth0: e1000_watchdog: NIC Link is Up 
100 Mbps Full Duplex, Flow Control: RX/TX
Sep 30 00:51:35 host kernel: NETDEV WATCHDOG: eth0: transmit timed out
Sep 30 00:51:37 host kernel: e1000: eth0: e1000_watchdog: NIC Link is Up 
100 Mbps Full Duplex, Flow Control: RX/TX
---------------------------------------------
After some conversation with my collocation provider (changing cables and 
switch port) i've searched google to same errors and found some advises to 
use ethtool -k tso off, but this is not work with my kernel/distribution.
Then i swapped just e1000 driver in 2.4.35 to older, from 2.4.31.
Now everything works, without loosing link.

Regards, Dmitry

----- End forwarded message -----
