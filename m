From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH v2 net 0/6] Marvell Armada XP/370/38X Neta fixes
Date: Fri, 27 Nov 2015 16:44:20 +0100
Message-ID: <1448639066-13074-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, mw@semihalf.com,
	jaz@semihalf.com, tn@semihalf.com
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:35826 "EHLO
	mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754843AbbK0Poe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 10:44:34 -0500
Received: by lfdl133 with SMTP id l133so132899086lfd.2
        for <netdev@vger.kernel.org>; Fri, 27 Nov 2015 07:44:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I updated the mvneta fixes patchset with minor corrections suggested by
Thomas Petazzoni.

I will be greatful for a feedback.

Best regards,
Marcin Wojtas

Changes from v2:
* Style fixes in patch updating mbus protection
* Remove redundant stable notifications except for patch 4/6

Changes from v1:
* update MBUS windows access protection register once, after whole loop
* add fixing value of MVNETA_RXQ_INTR_ENABLE_ALL_MASK
* add fixing error path for skb_build()
* add possibility of setting custom TX IP checksum limit in DT property

Marcin Wojtas (6):
  net: mvneta: add configuration for MBUS windows access protection
  net: mvneta: fix bit assignment in MVNETA_RXQ_CONFIG_REG
  net: mvneta: fix bit assignment for RX packet irq enable
  net: mvneta: fix error path for building skb
  net: mvneta: enable setting custom TX IP checksum limit
  net: mvneta: enable IP checksum with jumbo frames for Armada 38x on
    Port0

 .../bindings/net/marvell-armada-370-neta.txt       |  6 ++++
 arch/arm/boot/dts/armada-38x.dtsi                  |  1 +
 drivers/net/ethernet/marvell/mvneta.c              | 33 ++++++++++++++++++----
 3 files changed, 34 insertions(+), 6 deletions(-)

-- 
1.8.3.1
