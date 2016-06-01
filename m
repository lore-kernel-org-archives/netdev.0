From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 2/2] ARM: dts: imx6: tag boards that have the HW
 workaround for ERR006687
Date: Wed, 1 Jun 2016 17:17:29 +0100
Message-ID: <20160601161729.GB19428@n2100.arm.linux.org.uk>
References: <1464794983-31484-1-git-send-email-l.stach@pengutronix.de>
 <1464794983-31484-3-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shawn Guo <shawnguo@kernel.org>, Fugang Duan <fugang.duan@nxp.com>,
	devicetree@vger.kernel.org, patchwork-lst@pengutronix.de,
	kernel@pengutronix.de, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:47470 "EHLO
	pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033AbcFAQTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 12:19:46 -0400
Content-Disposition: inline
In-Reply-To: <1464794983-31484-3-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 01, 2016 at 05:29:43PM +0200, Lucas Stach wrote:
> @@ -97,6 +97,7 @@
>  	phy-reset-gpios = <&gpio3 31 0>;
>  	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
>  			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
> +	fsl,err006687-war-present;

war?  Any reason not to spell it out, or use the more natural
abbreviation "wa"?

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
