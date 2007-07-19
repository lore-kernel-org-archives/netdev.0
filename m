From: dhananjay@netxen.com
Subject: [PATCH 0/0] netxen: bug fixes for IMEZ adapters on pblades
Date: Thu, 19 Jul 2007 14:33:21 +0530
Message-ID: <20070719090321.514112712@netxen.com>
Cc: rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.199.144.227] ([203.199.144.227]:1467 "EHLO
	stellar.unminc.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752515AbXGSJMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 05:12:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Couple of bug fixes for netxen IMEZ adapter on powerpc blades. The firmware
must be loaded during probe and free PCI resources during module unload.
Please apply against #upstream-fixes.

 drivers/net/netxen/netxen_nic.h          |    3 +-
 drivers/net/netxen/netxen_nic_main.c     |   48 +++++++++++++++---------------
 2 files changed, 25 insertions(+), 26 deletions(-)
 
