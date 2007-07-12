From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 0/2] qeth patches for 2.6.23
Date: Thu, 12 Jul 2007 12:51:33 +0200
Message-ID: <20070712105133.165267000@linux.vnet.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:56921 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761016AbXGLKyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 06:54:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--
second attempt to send qeth patches: 
This time with corrected sender address - sorry for the confusion.
 
two qeth patches for 2.6.23:
- scatter-gather patch improves handling of large incoming packets
- barrier patch is required due to a recent removal of 'volatile'
  from atomic_t in include/asm-s390/atomic.h
