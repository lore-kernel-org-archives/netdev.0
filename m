From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 0/5] atl1: miscellaneous cleanup and code reorganization
Date: Sun, 15 Jul 2007 11:03:24 -0500
Message-ID: <11845154092908-git-send-email-jacliburn@bellsouth.net>
Cc: jacliburn@bellsouth.net, csnook@redhat.com,
	atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf18aec.mail.bellsouth.net ([205.152.59.66]:33954 "EHLO
	imf18aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759050AbXGOQDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 12:03:31 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please accept the following patches for the atl1 driver.

atl1: remove irq_sem
atl1: header file cleanup
atl1: cleanup atl1_main
atl1: fix excessively indented code
atl1: reorder atl1_main functions

 drivers/net/atl1/atl1.h      |  156 ++--
 drivers/net/atl1/atl1_main.c | 2176 +++++++++++++++++++++---------------------
 2 files changed, 1172 insertions(+), 1160 deletions(-)

