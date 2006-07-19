From: Ralf Baechle <ralf@linux-mips.org>
Subject: ipw2200: Driver lockup
Date: Wed, 19 Jul 2006 10:28:34 -0400
Message-ID: <20060719142833.GA21345@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:32231 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1030230AbWGSTbD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 15:31:03 -0400
Received: from localhost.localdomain ([127.0.0.1]:15261 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S7619142AbWGSTbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2006 20:31:02 +0100
Received: from denk.linux-mips.net (denk.linux-mips.net [127.0.0.1])
	by bacchus.dhis.org (8.13.7/8.13.4) with ESMTP id k6JJV4RP004052
	for <netdev@vger.kernel.org>; Wed, 19 Jul 2006 15:31:05 -0400
Received: (from ralf@localhost)
	by denk.linux-mips.net (8.13.7/8.13.7/Submit) id k6JESYPu021839
	for netdev@vger.kernel.org; Wed, 19 Jul 2006 10:28:34 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I got the driver to die several times under the extreme condition at the
KS / OLS with dozens to hundreds of other machines in the same room.  The
last kernel message I got from about the time when wireless died was

  eth1: NETDEV_TX_BUSY returned; driver should report queue full via ieee_device->is_queue_full.

  Ralf
