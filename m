From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next v2 0/2] drivers: xgene: Add support RGMII TX/RX delay configuration
Date: Mon, 26 Oct 2015 15:25:14 -0700
Message-ID: <1445898316-21372-1-git-send-email-isubramanian@apm.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com, f.fainelli@gmail.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33786 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbbJZWYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 18:24:38 -0400
Received: by pabla5 with SMTP id la5so7305530pab.0
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 15:24:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

X-Gene RGMII ethernet controller has a RGMII bridge that performs the
task of converting the RGMII signal {RX_CLK,RX_CTL, RX_DATA[3:0]} from
PHY to GMII signal {RX_DV,RX_ER,RX_DATA[7:0]} and vice versa.  This
RGMII bridge has a provision to internally delay the input RX_CLK and
the output TX_CLK using configuration registers. This will help in
maintain the CLK-CTL delay relationship in various operating
conditions.

This patch adds support RGMII TX/RX delay configuration.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---

Iyappan Subramanian (2):
  drivers: net: xgene: Add support RGMII TX/RX delay configuration
  Documentation: dts: xgene: Add TX/RX delay field

 .../devicetree/bindings/net/apm-xgene-enet.txt     | 10 +++++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c     |  8 +++-
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   | 49 ++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |  2 +
 5 files changed, 69 insertions(+), 1 deletion(-)

-- 
1.9.1
