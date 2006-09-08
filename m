From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 0/2] pcnet32:  NAPI support
Date: Fri, 8 Sep 2006 15:39:09 -0700
Message-ID: <20060908223909.GA24356@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:2748 "EHLO e34.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751214AbWIHWiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2006 18:38:25 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k88McOMe028112
	for <netdev@vger.kernel.org>; Fri, 8 Sep 2006 18:38:24 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k88McOGK277560
	for <netdev@vger.kernel.org>; Fri, 8 Sep 2006 16:38:24 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k88McN3q021403
	for <netdev@vger.kernel.org>; Fri, 8 Sep 2006 16:38:23 -0600
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches to the pcnet32 driver implement NAPI and respond to some
other suggestions found during NAPI development and testing.

The comments from Francois Romieu regarding using spin_lock instead of
spin_lock_irqsave were investigated, but since interrupts have to be
disabled to prevent the interrupt handler from deadlocking, and since I
would probably forget sometime, it is safer to leave the locking as it
is.  The requested mmiowb calls were added.

Please appply to 2.6.19.

1/2 NAPI implementation.
2/2 Magic number cleanup.
-- 
Don Fry
brazilnut@us.ibm.com
