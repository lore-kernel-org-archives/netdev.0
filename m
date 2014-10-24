From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next v3 0/5] cleanup on resource check
Date: Fri, 24 Oct 2014 07:42:05 +0530
Message-ID: <1414116730-4590-1-git-send-email-varkab@cdac.in>
Cc: davem@davemloft.net, sergei.shtylyov@cogentembedded.com,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:45422 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbaJXCNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 22:13:43 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so546101pdj.41
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 19:13:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series removes the duplication of sanity check for
platform_get_resource() return resource. It will be checked 
with devm_ioremap_resource()

changes since v2:
	- Merge #1 and #2 patches into single patch
	- remove the comment

changes since v1:
	- remove NULL dereference on resource_size()

Varka Bhadram (5):
  ethernet: wiznet: remove unnecessary check
  ethernet: apm: xgene: remove unnecessary check
  ethernet: marvell: remove unnecessary check
  ethernet: renesas: remove unnecessary check
  ethernet: samsung: sxgbe: remove unnecessary check

 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   |   12 ------------
 drivers/net/ethernet/marvell/pxa168_eth.c          |    6 ++----
 drivers/net/ethernet/renesas/sh_eth.c              |    8 ++------
 .../net/ethernet/samsung/sxgbe/sxgbe_platform.c    |    3 ---
 drivers/net/ethernet/wiznet/w5100.c                |    6 ++----
 drivers/net/ethernet/wiznet/w5300.c                |    6 ++----
 6 files changed, 8 insertions(+), 33 deletions(-)

-- 
1.7.9.5
