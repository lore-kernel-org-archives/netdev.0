From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [RFC] iproute2: sch_rr support in tc
Date: Mon, 04 Jun 2007 14:42:21 -0700
Message-ID: <20070604214221.1546.88862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49542 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751447AbXFDVmX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 17:42:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is to support the new sch_rr (round-robin) qdisc being proposed
in NET for multiqueue network device support in the Linux network stack.
It uses q_prio.c as the template, since the qdiscs are nearly identical,
outside of the ->dequeue() routine.

I'm soliciting feedback for a 2.6.23 multiqueue submission.  Thanks.

-- 
PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
