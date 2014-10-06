From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/8] gianfar: ARM port driver updates (1/2)
Date: Sun, 05 Oct 2014 21:27:22 -0400 (EDT)
Message-ID: <20141005.212722.1867743289839811370.davem@davemloft.net>
References: <1412352169-14414-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Li.Xiubo@freescale.com,
	Shruti@freescale.com
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbaJFB1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 21:27:24 -0400
In-Reply-To: <1412352169-14414-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Fri, 3 Oct 2014 19:02:41 +0300

> This is the first round of driver protability fixes and clean-up
> with the main purpose to make gianfar portable on ARM, for the ARM
> based SoC that integrates the eTSEC ethernet controller - "ls1021a".
> The patches primarily address compile time errors, when compiling
> gianfar on ARM.  They replace PPC specific functions and macros
> with architecture independent ones, solve arch specific header
> inclusions, guard code that relates to PPC only, and even address
> some simple endianess issues (see MAC address setup patch).
> The patches addressing the bulk of remaining endianess issues,
> like handling DMA fields (BD and FCB), will follow with the sencond
> round.
> These patches were verified on the ls1021a SoC.

If more endianness fixes are necessary and "will follow with the
second round", I do not see how you could have verified specifically
these changes on the ls1021a.
