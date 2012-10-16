From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 1/5] ARM: OMAP2+: gpmc: Fix kernel BUG for DT boot mode
Date: Tue, 16 Oct 2012 10:48:36 -0700
Message-ID: <20121016174835.GV15569@atomide.com>
References: <cover.1350327320.git.richardcochran@gmail.com>
 <41d66042625157d089e9c9532030a6831e79c641.1350327324.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>,
	David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	"hvaibhav@ti.com" <hvaibhav@ti.com>, Afzal Mohammed <afzal@ti.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-04-ewr.mailhop.org ([204.13.248.74]:27824 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755124Ab2JPRsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 13:48:40 -0400
Content-Disposition: inline
In-Reply-To: <41d66042625157d089e9c9532030a6831e79c641.1350327324.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Richard Cochran <richardcochran@gmail.com> [121015 12:18]:
> From: hvaibhav@ti.com <hvaibhav@ti.com>
> 
> With recent changes in omap gpmc driver code, in case of DT
> boot mode, where bootloader does not configure gpmc cs space
> will result into kernel BUG() inside gpmc_mem_init() function,
> as gpmc cs0 gpmc_config7[0].csvalid bit is set to '1' and
> gpmc_config7[0].baseaddress is set to '0' on reset.
> 
> This use-case is applicable for any board/EVM which doesn't have
> any peripheral connected to gpmc cs0, for example BeagleXM and
> BeagleBone, so DT boot mode fails.
> 
> This patch adds of_have_populated_dt() check before creating
> device, so that for DT boot mode, gpmc probe will not be called
> which is expected behavior, as gpmc is not supported yet from DT.

I'm applying this one into omap-for-v3.7-rc1/fixes-part2.

Next time, please also cc linux-omap@vger.kernel.org for series
like this. I'm sure the people reading the omap list are interested
in these.

Regards,

Tony
