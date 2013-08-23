From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] fs_enet: cleanup clock API use
Date: Thu, 22 Aug 2013 22:14:24 -0700 (PDT)
Message-ID: <20130822.221424.1506725486871381537.davem@davemloft.net>
References: <1377201313-10420-1-git-send-email-agust@denx.de>
	<1377201313-10420-2-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pantelis.antoniou@gmail.com,
	vbordug@ru.mvista.com, gsi@denx.de
To: agust@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754174Ab3HWFOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 01:14:36 -0400
In-Reply-To: <1377201313-10420-2-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anatolij Gustschin <agust@denx.de>
Date: Thu, 22 Aug 2013 21:55:13 +0200

> From: Gerhard Sittig <gsi@denx.de>
> 
> make the Freescale ethernet driver get, prepare and enable the FEC clock
> during probe(); disable and unprepare the clock upon remove(), put is
> done by the devm approach; hold a reference to the clock over the period
> of use.
> 
> clock lookup is non-fatal as not all platforms provide clock specs in
> their device tree; failure to enable specified clocks is fatal.
> 
> Signed-off-by: Gerhard Sittig <gsi@denx.de>
> Signed-off-by: Anatolij Gustschin <agust@denx.de>

Applied.
