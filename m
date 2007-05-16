From: Urs Thuermann <urs@isnogud.escape.de>
Subject: [patch 0/7] CAN: Add new PF_CAN protocol family
Date: Wed, 16 May 2007 16:51:00 +0200
Message-ID: <20070516145100.29877.0@janus.isnogud.escape.de>
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:58939 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756300AbXEPPUM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 11:20:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series applies against linux-2.6.22-rc1-git4.  It adds a new
protocol family to Linux for communication on the CAN (Controller Area
Network) using the socket API.

The current implementation supports two protocols in the family, a raw
protocol for sending and receiving raw CAN frames, and a broadcast
manager protocol, which effeciently handles periodically sent
broadcast messages, which are typical in CAN environments.

There is also a virtual CAN network driver which only loops back sent
CAN frames.  Drivers for real CAN hardware are also being worked on
and are nearly complete.  These will be released later, or you can find
them in the subversion repository at
http://svn.berlios.de/svnroot/repos/socketcan.

Additional information about the concepts of the CAN protocol family
can be found in the file Documentation/networking/can.txt, added by
patch 7/7.

Userspace tools (can-utils) and test suites for the different CAN
protocols can also be found in the subversion repository.
--
