From: Kumar Gala <galak@kernel.crashing.org>
Subject: [RFC] Make board force selection of PHYLIB
Date: Tue, 3 Jun 2008 09:47:19 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0806030945540.21537@blarg.am.freescale.net>
References: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net>
 <484419EE.5040503@garzik.org> <1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org>
 <48442239.7090906@garzik.org> <BF15FEBB-4876-4B16-915B-1D21BF989DA8@kernel.crashing.org>
 <83820D83-487C-4586-9867-F4226A87A276@freescale.com> <48445851.4090105@garzik.org>
 <095F258F-72DD-4F27-A457-A57D9FAA1E76@kernel.crashing.org>
 <48448020.5020407@freescale.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, adrian.bunk@movial.fi
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:36093 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753740AbYFCOro (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 10:47:44 -0400
In-Reply-To: <48448020.5020407@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

How is this as a fix.

- k

diff --git a/arch/powerpc/platforms/85xx/Kconfig b/arch/powerpc/platforms/85xx/Kconfig
index 7ff29d5..9e5c884 100644
--- a/arch/powerpc/platforms/85xx/Kconfig
+++ b/arch/powerpc/platforms/85xx/Kconfig
@@ -34,6 +34,7 @@ config MPC85xx_MDS
 	bool "Freescale MPC85xx MDS"
 	select DEFAULT_UIMAGE
 	select QUICC_ENGINE
+	select PHYLIB if GIANFAR=m
 	help
 	  This option enables support for the MPC85xx MDS board

