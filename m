From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next 0/6] cleanup on resource check
Date: Wed, 22 Oct 2014 09:46:20 +0530
Message-ID: <1413951386-29645-1-git-send-email-varkab@cdac.in>
References: <N>
Cc: Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:52678 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbaJVETa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 00:19:30 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so2858721pab.30
        for <netdev@vger.kernel.org>; Tue, 21 Oct 2014 21:19:30 -0700 (PDT)
In-Reply-To: <N>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series removes the duplication of sanity check for
platform_get_resource() return resource. It will be checked 
with devm_ioremap_resource()

Varka Bhadram (6):
  ethernet: wiznet: remove unnecessary check
  ethernet: wiznet: remove unnecessary check
  ethernet: apm: xgene: remove unnecessary check
  ethernet: marvell: remove unnecessary check
  ethernet: renesas: remove unnecessary check
  ethernet: samsung: sxgbe: remove unnecessary check

 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   |   12 ------------
 drivers/net/ethernet/marvell/pxa168_eth.c          |    6 ++----
 drivers/net/ethernet/renesas/sh_eth.c              |    4 ----
 .../net/ethernet/samsung/sxgbe/sxgbe_platform.c    |    3 ---
 drivers/net/ethernet/wiznet/w5100.c                |    3 +--
 drivers/net/ethernet/wiznet/w5300.c                |    3 +--
 6 files changed, 4 insertions(+), 27 deletions(-)

-- 
1.7.9.5
