From: Holger Schurig <holgerschurig@gmail.com>
Subject: RE: [PATCH v2 1/2] ARM: imx6: disable deeper idle states when FEC is active w/o HW workaround
Date: Mon, 06 Jun 2016 13:04:12 +0200
Message-ID: <87a8iypoib.fsf@gmail.com>
References: <1464971480-9203-1-git-send-email-l.stach@pengutronix.de> <VI1PR0401MB1855AA40FA576AF677A68E6FFF5C0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "devicetree\@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel\@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"kernel\@pengutronix.de" <kernel@pengutronix.de>,
	"patchwork-lst\@pengutronix.de" <patchwork-lst@pengutronix.de>
To: Fugang Duan <fugang.duan@nxp.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Shawn Guo <shawnguo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37602 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127AbcFFLEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 07:04:16 -0400
In-Reply-To: <VI1PR0401MB1855AA40FA576AF677A68E6FFF5C0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You just config the gpio irq like below patches:
> bc20a5d6da71 (ARM: dts: imx6qdl-sabreauto: use GPIO_6 for FEC interrupt.)
> 6261c4c8f13e (ARM: dts: imx6qdl-sabrelite: use GPIO_6 for FEC interrupt.)

But this is per-board, e.g. not board-agnostic??!?!   Some board might
have uses GPIO6 for other things and rendered it unusable for this ...
