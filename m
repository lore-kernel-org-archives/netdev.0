From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 0/2] [AF_IUCV] fixes for net-2.6.24
Date: Thu, 04 Oct 2007 16:46:08 +0200
Message-ID: <20071004144608.880229000@linux.vnet.ibm.com>
Cc: heiko.carstens@de.ibm.com
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:47638 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755894AbXJDOs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 10:48:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-- 
Dave,

the following 2 patches are intended for 2.6.24 and contain:
- removal of static declarations in af_iucv header file
- postpone receival of inbound packets in af_iucv
