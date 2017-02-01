From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCH 0/2] sh_eth: fixes for MagicPacket handling
Date: Wed,  1 Feb 2017 15:41:53 +0100
Message-ID: <20170201144155.17123-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-renesas-soc@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-4.sys.kth.se ([130.237.48.193]:44059 "EHLO
        smtp-4.sys.kth.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751322AbdBAOnl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 09:43:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This series contain two fixes for MagicPacket handling. It's based on 
top of net-next and is tested on Koelsch.

Niklas Söderlund (2):
  sh_eth: align usage of sh_eth_modify() with rest of driver
  sh_eth: fix wakeup event reporting from MagicPacket

 drivers/net/ethernet/renesas/sh_eth.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

-- 
2.11.0
