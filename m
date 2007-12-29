From: "Joakim Tjernlund" <joakim.tjernlund@transmode.se>
Subject: RE: [PATCH 1/3] [NET] phy/fixed.c: rework to not duplicate PHY layerfunctionality
Date: Sat, 29 Dec 2007 18:13:08 +0100
Message-ID: <003c01c84a3e$15d3a9c0$02ac10ac@Jocke>
References: <20071206225121.31080.86606.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"'linuxppc-dev'" <linuxppc-dev@ozlabs.org>
To: "'Vitaly Bordug'" <vitb@kernel.crashing.org>,
	"'Paul Mackerras'" <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:62119 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753539AbXL2RNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2007 12:13:25 -0500
In-reply-to: <20071206225121.31080.86606.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: 
> linuxppc-dev-bounces+joakim.tjernlund=transmode.se@ozlabs.org 
> [mailto:linuxppc-dev-bounces+joakim.tjernlund=transmode.se@ozl
> abs.org] On Behalf Of Vitaly Bordug
> Sent: den 6 december 2007 23:51
> To: Paul Mackerras
> Cc: netdev@vger.kernel.org; linuxppc-dev
> Subject: [PATCH 1/3] [NET] phy/fixed.c: rework to not 
> duplicate PHY layerfunctionality
> 
> 
> With that patch fixed.c now fully emulates MDIO bus, thus no need
> to duplicate PHY layer functionality. That, in turn, drastically
> simplifies the code, and drops down line count.
> 
> As an additional bonus, now there is no need to register MDIO bus
> for each PHY, all emulated PHYs placed on the platform fixed MDIO bus.
> There is also no more need to pre-allocate PHYs via .config option,
> this is all now handled dynamically.
> 
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>
> Acked-by: Jeff Garzik <jeff@garzik.org>

What happened to this patch set? Is it sitting in a tree somewhere waiting
for 2.4.25 or does it need more work?

 Jocke

