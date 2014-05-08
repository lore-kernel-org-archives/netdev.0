From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net] Altera TSE: Fix Sparse errors and Cppcheck warnings
Date: Thu,  8 May 2014 13:15:39 -0500
Message-ID: <1399572940-32233-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33203 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754876AbaEHST5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 14:19:57 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so3190709pab.36
        for <netdev@vger.kernel.org>; Thu, 08 May 2014 11:19:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses sparse errors and warnings and a few cppcheck warnings.

If you find this patch acceptable, please consider this for inclusion into
the Altera TSE driver source code. 

Thank you

Vince

Vince Bridgers (1):
  Altera TSE: Fix sparse errors and warnings

 drivers/net/ethernet/altera/Makefile             |    1 +
 drivers/net/ethernet/altera/altera_msgdma.c      |  110 ++++++-------
 drivers/net/ethernet/altera/altera_msgdmahw.h    |   13 +-
 drivers/net/ethernet/altera/altera_sgdma.c       |  181 +++++++++++-----------
 drivers/net/ethernet/altera/altera_sgdmahw.h     |   26 ++--
 drivers/net/ethernet/altera/altera_tse.h         |   47 ++++++
 drivers/net/ethernet/altera/altera_tse_ethtool.c |  108 ++++++++-----
 drivers/net/ethernet/altera/altera_tse_main.c    |  133 +++++++++-------
 drivers/net/ethernet/altera/altera_utils.c       |   20 +--
 drivers/net/ethernet/altera/altera_utils.h       |    8 +-
 10 files changed, 372 insertions(+), 275 deletions(-)

-- 
1.7.9.5
