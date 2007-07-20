From: dhananjay@netxen.com
Subject: [PATCH 0/2] netxen: bug fixes for multiport adapters
Date: Sat, 21 Jul 2007 00:37:49 +0530
Message-ID: <20070720190749.535704712@netxen.com>
Cc: rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.199.144.227] ([203.199.144.227]:1093 "EHLO
	stellar.unminc.com" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S935937AbXGTTSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 15:18:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches include fix for problem with 2nd port of multiport adapters
on IBM blades. Also improves interrupt handling for multiport adapters
avoiding interrupt flood after interrupt is down.

Generated against upstream-fixes.

 drivers/net/netxen/netxen_nic.h          |    3 +-
 drivers/net/netxen/netxen_nic_main.c     |   85 +++++++++++++++---------------
 2 files changed, 43 insertions(+), 45 deletions(-)

-- 
