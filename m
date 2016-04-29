From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 0/3] drivers: net: xgene: fix: Get channel number from device binding
Date: Fri, 29 Apr 2016 11:10:12 -0700
Message-ID: <1461953415-9741-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:32968 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbcD2SJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 14:09:53 -0400
Received: by mail-pf0-f177.google.com with SMTP id 206so51338033pfu.0
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 11:09:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds 'channel' property to get ethernet to CPU channel number,
thus decoupling the Linux driver from static resource selection.

v2: Address review comments from v1
- removed irq reference from Linux driver
- added 'channel' property to get ethernet to CPU channel number

v1:
- Initial version

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---

Iyappan Subramanian (3):
  drivers: net: xgene: Get channel number from device binding
  Documentation: dtb: xgene: Add channel property
  dtb: xgene: Add channel property

 Documentation/devicetree/bindings/net/apm-xgene-enet.txt |  2 ++
 arch/arm64/boot/dts/apm/apm-shadowcat.dtsi               |  1 +
 arch/arm64/boot/dts/apm/apm-storm.dtsi                   |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c         | 15 ++++++++++++++-
 4 files changed, 18 insertions(+), 1 deletion(-)

-- 
1.9.1
