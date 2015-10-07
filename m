From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3][RESEND] gianfar: Add WAKE_UCAST and
 "wake-on-filer" support
Date: Wed, 07 Oct 2015 04:20:27 -0700 (PDT)
Message-ID: <20151007.042027.1127620141901676719.davem@davemloft.net>
References: <1444054799-17876-1-git-send-email-claudiu.manoil@freescale.com>
	<1444054799-17876-3-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leoli@freescale.com,
	chenhui.zhao@freescale.com
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52874 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbbJGLEn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 07:04:43 -0400
In-Reply-To: <1444054799-17876-3-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Mon, 5 Oct 2015 17:19:59 +0300

> This enables eTSEC's filer (Rx parser) and the FGPI Rx
> interrupt (Filer General Purpose Interrupt) as a wakeup
> source event.
> 
> Upon entering suspend state, the eTSEC filer is given
> a rule to match incoming L2 unicast packets.  A packet
> matching the rule will be enqueued in the Rx ring and
> a FGPI Rx interrupt will be asserted by the filer to
> wakeup the system.  Other packet types will be dropped.
> On resume the filer table is restored to the content
> before entering suspend state.
> The set of rules from gfar_filer_config_wol() could be
> extended to implement other WoL capabilities as well.
> 
> The "fsl,wake-on-filer" DT binding enables this capability
> on certain platforms that feature the necessary power
> management infrastructure, targeting mainly printing and
> imaging applications.
> (refer to Power Management section of the SoC Ref Man)
> 
> Cc: Li Yang <leoli@freescale.com>
> Cc: Zhao Chenhui <chenhui.zhao@freescale.com>
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
> ---
> Whole series resent to the nedev list because the first
> two patches in the initial submission were sent to the
> linuxppc-dev list only.  Targets net-next.

Applied.
