From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 0/2] ARM: dts: NSP: Add built-in Ethernet switch nodes
Date: Fri,  8 Jul 2016 11:49:27 -0700
Message-ID: <1468003769-26959-1-git-send-email-f.fainelli@gmail.com>
Cc: devicetree@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com,
	jon.mason@broadcom.com, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com,
	linux-arm-kernel@lists.infradead.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36139 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756214AbcGHStc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 14:49:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is based on Broadcom/stblinux/devicetree/next which
contains proper support for the BCM958625HR board. To get working
Ethernet switch and CPU Ethernet support, the following dependencies
based on David Miller's net-next tree are required:

- Jon Mason's BGMAC/AMAC support: https://marc.info/?t=146793308300002&r=1&w=3
- dsa/b53 support for NSP switch: https://marc.info/?l=linux-netdev&m=146800324531914&w=3

Florian Fainelli (2):
  ARM: dts: NSP: Add Switch Register Access Block node
  ARM: dts: NSP: Add BCM958625HR switch ports

 arch/arm/boot/dts/bcm-nsp.dtsi    | 11 +++++++++
 arch/arm/boot/dts/bcm958625hr.dts | 49 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+)

-- 
2.7.4
