From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: FEC driver hangs hardware on i.MX6SX
Date: Sun, 20 Jul 2014 08:06:38 +0000
Message-ID: <11d5e68443c446eaa43def6c3e14aad4@BLUPR03MB373.namprd03.prod.outlook.com>
References: <20140720025732.GF8537@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	Shawn Guo <Shawn.Guo@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Shawn Guo <Shawn.Guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0184.outbound.protection.outlook.com ([207.46.163.184]:36129
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750754AbaGTIGl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 04:06:41 -0400
In-Reply-To: <20140720025732.GF8537@dragon>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Shawn,

>-----Original Message-----
>From: Shawn Guo [mailto:shawn.guo@freescale.com]
>Sent: Sunday, July 20, 2014 10:58 AM
>To: Duan Fugang-B38611
>Cc: Li Frank-B20596; David S. Miller; Guo Shawn-R65073;
>netdev@vger.kernel.org; linux-arm-kernel@lists.infradead.org
>Subject: FEC driver hangs hardware on i.MX6SX
>
>Hi Fugang,
>
>Your commit e8fcfcd5684a (net: fec: optimize the clock management to save
>power) landed on mainline with v3.16-rc1.  It causes a hardware hang on
>i.MX6SX, if the rootfs is not on NFS but something else like MMC.
>
>I think the cause is that PTP is still accessing registers after FEC
>driver calls fec_enet_clk_enable(ndev, false) to disable FEC clocks.
>Can you please try to provide a fix for this regression soon?
>

Yes, you analyze is right. We had the related patch on internal trees since imx6sx bringup.
I will try to move the patch to upstream.

Thanks,
Andy
