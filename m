From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net 0/2] Fix duplicate #include headers
Date: Sat,  5 Apr 2014 00:28:59 -0600
Message-ID: <1396679341-23502-1-git-send-email-sakiwit@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:34395 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbaDEGcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Apr 2014 02:32:31 -0400
Received: by mail-pd0-f173.google.com with SMTP id z10so4255552pdj.18
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 23:32:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This tiny series fixes the same issue of duplicate #include headers.

Jean Sacren (2):
  sxgbe: fix duplicate #include headers
  mac802154: fix duplicate #include headers

 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c | 1 -
 net/mac802154/mib.c                            | 1 -
 2 files changed, 2 deletions(-)
