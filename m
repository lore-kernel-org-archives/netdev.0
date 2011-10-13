From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH 0/8] caif-hsi: Bug-fixes for CAIF HSI.
Date: Thu, 13 Oct 2011 23:29:21 +0200
Message-ID: <1318541369-8141-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dmitry.tarnyagin@stericsson.com, daniel.martensson@stericsson.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:41517 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753941Ab1JMW3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 18:29:55 -0400
Received: from ignis-smin.broadpark.no ([80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LT0001DJX1K7670@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Thu, 13 Oct 2011 23:29:44 +0200 (CEST)
Received: from localhost.localdomain ([80.203.143.169])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LT000HN3X1J7Y00@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Thu, 13 Oct 2011 23:29:44 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch-set contains our latest pile of HSI bug fixes and
performance improvements for CAIF HSI driver.

Patches should apply cleanly on both net and net-next.

Regards,
Sjur

Daniel Martensson (4):
  caif-hsi: Making read and writes asynchronous.
  caif-hsi: HSI-Platform device register and unregisters itself
  caif-hsi: Added sanity check for length of CAIF frames
  caif-hsi: Added recovery check of CA wake status.

Dmitry Tarnyagin (3):
  caif-hsi: Fixing a race condition in the caif_hsi code
  caif-hsi: Fix for wakeup condition problem
  caif-hsi: Make inactivity timeout configurable.

Sjur Br=C3=A6ndeland (1):
  caif-hsi: HSI Fix uninitialized data in HSI header

 drivers/net/caif/caif_hsi.c |  427 +++++++++++++++++++++++++----------=
--------
 include/net/caif/caif_hsi.h |   37 +++-
 2 files changed, 276 insertions(+), 188 deletions(-)
