From: Boris BREZILLON <b.brezillon@overkiz.com>
Subject: [PATCH 0/2] net/cadence/macb: add support for dt phy definition
Date: Thu, 22 Aug 2013 17:56:20 +0200
Message-ID: <1377186980-21902-1-git-send-email-b.brezillon@overkiz.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	Boris BREZILLON <b.brezillon@overkiz.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Russell King <linux@arm.linux.org.uk>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 7.mo3.mail-out.ovh.net ([46.105.57.200]:35270 "EHLO
	mo3.mail-out.ovh.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752951Ab3HVP5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 11:57:05 -0400
Received: from mail96.ha.ovh.net (b6.ovh.net [213.186.33.56])
	by mo3.mail-out.ovh.net (Postfix) with SMTP id 8C1F2FF9A3E
	for <netdev@vger.kernel.org>; Thu, 22 Aug 2013 17:57:04 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This patch series adds support for ethernet phy definition using device
tree.

This may help in moving some at91 boards to dt (some of them define an
interrupt pin).

Tested on samad31ek.

Best Regards,
Boris

Boris BREZILLON (2):
  net/cadence/macb: add support for dt phy definition
  ARM: at91/dt: define phy available on sama5d3 mother board

 arch/arm/boot/dts/sama5d3xmb.dtsi   |    8 +++++++
 drivers/net/ethernet/cadence/macb.c |   41 +++++++++++++++++++++++++++++------
 2 files changed, 42 insertions(+), 7 deletions(-)

-- 
1.7.9.5
