From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH] ucc_geth.c, make PHY device optional.
Date: Wed, 4 Jul 2007 21:13:32 +0800
Message-ID: <989B956029373F45A0B8AF0297081890D839B4@zch01exm26.fsl.freescale.net>
References: <1183539047.20673.216.camel@gentoo-jocke.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: "linuxppc-dev Development" <linuxppc-dev@ozlabs.org>,
	"Netdev" <netdev@vger.kernel.org>,
	"Fleming Andy-afleming" <afleming@freescale.com>
To: <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:59653 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757831AbXGDNLl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 09:11:41 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id l64DBcY3014855
	for <netdev@vger.kernel.org>; Wed, 4 Jul 2007 06:11:38 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id l64DBbWf018183
	for <netdev@vger.kernel.org>; Wed, 4 Jul 2007 08:11:37 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <1183539047.20673.216.camel@gentoo-jocke.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

{snip}
> 
> OK, but then a new property in PHY node is needed which holds
> the initial speed and duplex.
> initial-phy-capacity = <speed duplex> ?
> This should be useful for real PHYs too if, for instance, autoneg
isn't
> working/supported/wanted.
> 
> Maybe it should be:
> initial-phy-capacity = <speed duplex autoneg>
> or
> initial-phy-capability = <speed duplex autoneg>

How about separate autoneg to a property "dumb-phy", which indicates the
PHY/switch doesn't provide MII register interface.  Therefore, it should
use the fixed speed and duplex from device node rather than registers.

- Leo
