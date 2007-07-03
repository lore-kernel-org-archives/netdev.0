From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH] ucc_geth.c, make PHY device optional.
Date: Tue, 3 Jul 2007 11:42:39 +0800
Message-ID: <989B956029373F45A0B8AF0297081890D837CB@zch01exm26.fsl.freescale.net>
References: <012701c7bd0c$64fe67c0$0e67a8c0@Jocke>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>,
	"linuxppc-dev Development" <linuxppc-dev@ozlabs.org>,
	"Netdev" <netdev@vger.kernel.org>,
	"Fleming Andy-afleming" <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:34171 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753072AbXGCDkx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 23:40:53 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id l633ejho024280
	for <netdev@vger.kernel.org>; Mon, 2 Jul 2007 20:40:46 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id l633eil0007361
	for <netdev@vger.kernel.org>; Mon, 2 Jul 2007 22:40:45 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <012701c7bd0c$64fe67c0$0e67a8c0@Jocke>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org] On
> Behalf Of Joakim Tjernlund
> Sent: Tuesday, July 03, 2007 8:52 AM
> To: 'linuxppc-dev Development'; 'Netdev'; Li Yang-r58472
> Subject: [PATCH] ucc_geth.c, make PHY device optional.
> 
> > This patch makes the PHY optional for ucc_geth.c ethernet driver.
> > This is useful to support a direct mii to mii connection to, for
example,
> > a onboard swicth.
> >
> > Signed-off-by: Joakim Tjernlund <joakim.tjernlund@transmode.se>
> ----
Hi Joakim,

I'm wondering if we really need to have the option to disable phylib.
Actually we have made phylib selected by default for ucc_geth.  Many L2
switch chips have the capacity to be controlled.  Therefore they can be
managed as a phy device.  For the MII interface which is not
configurable, shouldn't we use the fixed phy support from Vitaly?

- Leo
