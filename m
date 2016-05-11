From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -next 0/4] net: w5100: collection of small changes
Date: Wed, 11 May 2016 15:30:23 +0900
Message-ID: <1462948227-21276-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33480 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbcEKGaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 02:30:39 -0400
Received: by mail-pf0-f194.google.com with SMTP id y7so3039504pfb.0
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 23:30:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series for w5100 driver includes a cleanup with no functional
change, two fixes, and adding a functionality.  Each change is relatively
small.

Akinobu Mita (4):
  net: w5100: remove unused is_w5200()
  net: w5100: fix MAC filtering for W5500
  net: w5100: increase TX timeout period
  net: w5100-spi: add support to specify MAC address by device tree

 drivers/net/ethernet/wiznet/w5100-spi.c |  4 +++-
 drivers/net/ethernet/wiznet/w5100.c     | 29 +++++++++++++++++------------
 drivers/net/ethernet/wiznet/w5100.h     |  3 ++-
 3 files changed, 22 insertions(+), 14 deletions(-)

-- 
2.7.4
