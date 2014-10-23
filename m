From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next v2 0/6] cleanup on resource check
Date: Thu, 23 Oct 2014 07:28:45 +0530
Message-ID: <1414029531-5067-1-git-send-email-varkab@cdac.in>
Cc: davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:43812 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801AbaJWB7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 21:59:06 -0400
Received: by mail-pa0-f50.google.com with SMTP id eu11so107409pac.23
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 18:59:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series removes the duplication of sanity check for
platform_get_resource() return resource. It will be checked 
with devm_ioremap_resource()

changes since v1:
	- remove NULL dereference on resource_size()

Varka Bhadram (6):
  ethernet: wiznet: remove unnecessary check
  ethernet: wiznet: remove unnecessary check
  ethernet: apm: xgene: remove unnecessary check
  ethernet: marvell: remove unnecessary check
  ethernet: renesas: remove unnecessary check
  ethernet: samsung: sxgbe: remove unnecessary check

 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   |   12 ------------
 drivers/net/ethernet/marvell/pxa168_eth.c          |    6 ++----
 drivers/net/ethernet/renesas/sh_eth.c              |    9 +++------
 .../net/ethernet/samsung/sxgbe/sxgbe_platform.c    |    3 ---
 drivers/net/ethernet/wiznet/w5100.c                |    6 ++----
 drivers/net/ethernet/wiznet/w5300.c                |    6 ++----
 6 files changed, 9 insertions(+), 33 deletions(-)

-- 
1.7.9.5
