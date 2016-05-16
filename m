From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: RE: [PATCH 2/2] net: ethernet: gianfar: use
 phy_ethtool_{get|set}_link_ksettings
Date: Mon, 16 May 2016 11:32:08 +0000
Message-ID: <DB4PR04MB379DD330FD1D17EB14EA6BC96770@DB4PR04MB379.eurprd04.prod.outlook.com>
References: <1463355009-19803-1-git-send-email-tremyfr@gmail.com>
 <1463355009-19803-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0095.outbound.protection.outlook.com ([157.55.234.95]:7944
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751077AbcEPLru convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 07:47:50 -0400
In-Reply-To: <1463355009-19803-2-git-send-email-tremyfr@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Philippe Reynes [mailto:tremyfr@gmail.com]
>Sent: Monday, May 16, 2016 2:30 AM
>To: claudiu.manoil@freescale.com; davem@davemloft.net
>Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Philippe Reynes
><tremyfr@gmail.com>
>Subject: [PATCH 2/2] net: ethernet: gianfar: use
>phy_ethtool_{get|set}_link_ksettings
>
>There are two generics functions phy_ethtool_{get|set}_link_ksettings,
>so we can use them instead of defining the same code in the driver.
>

Assuming this is for net-next.git, since current net.git does not have
any of the *ksettings() function definitions.

Claudiu
