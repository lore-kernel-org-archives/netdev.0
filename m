From: Claudiu Manoil <claudiu.manoil@nxp.com>
Subject: RE: [PATCH 1/2] net: ethernet: gianfar: use phydev from struct
 net_device
Date: Mon, 16 May 2016 11:39:05 +0000
Message-ID: <DB4PR04MB379E3AB3AB9A553DEB034DE96770@DB4PR04MB379.eurprd04.prod.outlook.com>
References: <1463355009-19803-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0054.outbound.protection.outlook.com ([157.56.112.54]:64744
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750897AbcEPMMg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 08:12:36 -0400
In-Reply-To: <1463355009-19803-1-git-send-email-tremyfr@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Philippe Reynes [mailto:tremyfr@gmail.com]
>Sent: Monday, May 16, 2016 2:30 AM
>To: claudiu.manoil@freescale.com; davem@davemloft.net
>Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Philippe Reynes
><tremyfr@gmail.com>
>Subject: [PATCH 1/2] net: ethernet: gianfar: use phydev from struct net_device
>
>The private structure contain a pointer to phydev, but the structure
>net_device already contain such pointer. So we can remove the pointer
>phydev in the private structure, and update the driver to use the
>one contained in struct net_device.
>

Acked-by: Claudiu Manoil <claudiu.manoil@nxp.com>
