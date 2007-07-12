From: Ursula.Braun.braunu@de.ibm.com
Subject: [patch 0/2] qeth patches for 2.6.23
Date: Thu, 12 Jul 2007 09:50:59 +0200
Message-ID: <20070712075059.579991000@linux.vnet.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:17261 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757120AbXGLHx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 03:53:28 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-- 
two qeth patches for 2.6.23:
- scatter-gather patch improves handling of large incoming packets
- barrier patch is required due to a recent removal of 'volatile'
  from atomic_t in include/asm-s390/atomic.h
