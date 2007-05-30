From: Urs Thuermann <urs@isnogud.escape.de>
Subject: [patch 0/7] CAN: Add new PF_CAN protocol family, update
Date: Wed, 30 May 2007 15:11:23 +0200
Message-ID: <20070530131123.10843.0@janus.isnogud.escape.de>
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:41715 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752725AbXE3NPk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 09:15:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Dave,

this is the second post of the patch series that adds the PF_CAN
protocol family for the Controller Area Network.

Due to some feedback on the netdev-list and own reviews we have changed
the following:

* reduced RCU callback overhead when deleting receiver lists (thx to
  feedback from Paul E. McKenney).

* eliminated some code duplication in net/can/proc.c.

* renamed slock-29 and sk_lock-29 to slock-AF_CAN and sk_lock-AF_CAN in
  net/core/sock.c

* added entry for can.txt in Documentation/networking/00-INDEX

* added error frame definitions in include/linux/can/error.h, which are to
  be used by CAN network drivers.

This patch series applies against linux-2.6.22-rc3 and is derived from
Subversion revision r322 of http://svn.berlios.de/svnroot/repos/socketcan.
It doesn't touch anything in the kernel except for the allocation of a
couple of numbers for protocol, arp hw type, and a line discipline.

The realization of PF_CAN has been started at the end of 2002 and is
stable since mid-2006.  It's used in automation, naval applications and
several automotive R&D environments (e.g. for the Car2Car onboard unit in
http://www.its.dot.gov/vii).

Since, the code has been heavily used and tested and has been reviewed and
discussed intensively on the project mailing lists, we do not expect any
vital problems in this patch series.
Please apply it after a final review.

Thanks very much for your work!

Best regards,

Urs Thuermann
Oliver Hartkopp

--
