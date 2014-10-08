From: David Miller <davem@davemloft.net>
Subject: Re: [net v2 0/8] gianfar: ARM port driver updates (1/2)
Date: Tue, 07 Oct 2014 20:35:49 -0400 (EDT)
Message-ID: <20141007.203549.1962424453157341874.davem@davemloft.net>
References: <1412667875-18225-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Li.Xiubo@freescale.com,
	Shruti@freescale.com, kim.phillips@freescale.com
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755432AbaJHAfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 20:35:51 -0400
In-Reply-To: <1412667875-18225-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Tue, 7 Oct 2014 10:44:27 +0300

> This is the first round of driver portability fixes and clean-up
> with the main purpose to make gianfar portable on ARM, for the ARM
> based SoC that integrates the eTSEC ethernet controller - "ls1021a".
> The patches primarily address compile time errors, when compiling
> gianfar on ARM.  They replace PPC specific functions and macros
> with architecture independent ones, solve arch specific header
> inclusions, guard code that relates to PPC only, and even address
> some simple endianess issues (see MAC address setup patch).
> The patches addressing the bulk of remaining endianess issues,
> like handling DMA fields (BD and FCB), will follow with the second
> round.
> 
> Reviewed-by: Kim Phillips <kim.phillips@freescale.com>

Series applied, thanks.
