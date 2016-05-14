From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -next v2 0/4] net: w5100: collection of small changes
Date: Sat, 14 May 2016 14:55:46 +0900
Message-ID: <1463205350-7089-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Mike Sinkovsky <msink@permonline.ru>,
	"David S . Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35359 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbcENF4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 01:56:30 -0400
Received: by mail-pf0-f194.google.com with SMTP id b66so2926093pfb.2
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 22:56:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is the collection of relatively small changes for
w5100 driver which includes a cleanup with no functional change,
two fixes, and adding a functionality.

* Changes from v1
- Remove the watchdong_timeo assignment to set default tx timeout,
  suggested by David Miller.

Akinobu Mita (4):
  net: w5100: remove unused is_w5200()
  net: w5100: fix MAC filtering for W5500
  net: w5100: increase TX timeout period
  net: w5100-spi: add support to specify MAC address by device tree

 drivers/net/ethernet/wiznet/w5100-spi.c |  4 +++-
 drivers/net/ethernet/wiznet/w5100.c     | 28 ++++++++++++++++------------
 drivers/net/ethernet/wiznet/w5100.h     |  3 ++-
 3 files changed, 21 insertions(+), 14 deletions(-)

Cc: Mike Sinkovsky <msink@permonline.ru>
Cc: David S. Miller <davem@davemloft.net>
-- 
2.7.4
