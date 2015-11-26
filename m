From: Manoil Claudiu <claudiu.manoil@freescale.com>
Subject: RE: [PATCH 1/2] net: fsl: Don't use NO_IRQ to check return value of
 irq_of_parse_and_map()
Date: Thu, 26 Nov 2015 15:18:28 +0000
Message-ID: <SN1PR0301MB2046A41D466FE60A2A6924E99C040@SN1PR0301MB2046.namprd03.prod.outlook.com>
References: <1448539186-5756-1-git-send-email-broonie@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Mark Brown <broonie@kernel.org>,
	Shaohui Xie <Shaohui.Xie@freescale.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0119.outbound.protection.outlook.com ([65.55.169.119]:65225
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750930AbbKZPSc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 10:18:32 -0500
In-Reply-To: <1448539186-5756-1-git-send-email-broonie@kernel.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Mark Brown [mailto:broonie@kernel.org]
>Sent: Thursday, November 26, 2015 2:00 PM
>To: Manoil Claudiu-B08782 <claudiu.manoil@freescale.com>; Xie Shaohui-
>B21989 <Shaohui.Xie@freescale.com>; David S . Miller
><davem@davemloft.net>
>Cc: netdev@vger.kernel.org; Mark Brown <broonie@kernel.org>
>Subject: [PATCH 1/2] net: fsl: Don't use NO_IRQ to check return value of
>irq_of_parse_and_map()
>
>This driver can be built on arm64 but relies on NO_IRQ to check the return
>value of irq_of_parse_and_map() which fails to build on arm64 because the
>architecture does not provide a NO_IRQ. Fix this to correctly check the
>return value of irq_of_parse_and_map().
>
>Even on ARM systems where the driver was previously used the check was
>broken since on ARM NO_IRQ is -1 but irq_of_parse_and_map() returns 0 on
>error.
>
>Signed-off-by: Mark Brown <broonie@kernel.org>

Ack.
Suggesting the v2 patch below instead, adding a missing fix:
http://patchwork.ozlabs.org/patch/549126/
("[net,v2] gianfar: Don't use NO_IRQ to check return value of irq_of_parse_and_map()")

Thanks,
Claudiu
