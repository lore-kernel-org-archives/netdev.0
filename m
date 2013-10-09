From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] gianfar: Use mpc85xx support for errata detection
Date: Wed, 09 Oct 2013 14:02:51 -0400 (EDT)
Message-ID: <20131009.140251.1669096107735357420.davem@davemloft.net>
References: <1381339242-32030-1-git-send-email-claudiu.manoil@freescale.com>
	<1381339242-32030-2-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50181 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756014Ab3JISCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 14:02:53 -0400
In-Reply-To: <1381339242-32030-2-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Wed, 9 Oct 2013 20:20:41 +0300

> Use the macros and defines from mpc85xx.h to simplify
> and prevent errors in identifying a mpc85xx based SoC
> for errata detection.
> This should help enabling (and identifying) workarounds
> for various mpc85xx based chips and revisions.
> For instance, express MPC8548 Rev.2 as:
> (SVR_SOC_VER(svr) == SVR_8548) && (SVR_REV(svr) == 0x20)
> instead of:
> (pvr == 0x80210020 && mod == 0x8030 && rev == 0x0020)
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied.
