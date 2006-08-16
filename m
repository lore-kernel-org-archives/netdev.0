From: Jay Vosburgh <fubar@us.ibm.com>
Subject: e1000: ethtool -p + cable pull = system wedges hard
Date: Tue, 15 Aug 2006 17:37:55 -0700
Message-ID: <200608160037.k7G0btZt002839@death.nxdomain.ibm.com>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:41664 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750751AbWHPAh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 20:37:59 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7G0bv9u010346
	for <netdev@vger.kernel.org>; Tue, 15 Aug 2006 20:37:57 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7G0bubC260630
	for <netdev@vger.kernel.org>; Tue, 15 Aug 2006 20:37:56 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7G0buSX020231
	for <netdev@vger.kernel.org>; Tue, 15 Aug 2006 20:37:56 -0400
To: e1000-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Running both 2.6.17.6 plus the e1000 7.2.7 from sourceforge, or
the e1000 in netdev-2.6#upstream (7.1.9-k4).

	Starting up "ethtool -p ethX" then unplugging the cable
connected to the identified port is causing my system to completely
freeze; even sysrq is unresponsive.  I'm running on a 2-way x86 box,
with an 82545GM.

	Is this by any chance a known problem?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
