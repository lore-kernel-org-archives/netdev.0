From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] gianfar: Enable eTSEC-A002 erratum w/a for all
 parts
Date: Wed, 09 Oct 2013 14:02:44 -0400 (EDT)
Message-ID: <20131009.140244.1085107412533674383.davem@davemloft.net>
References: <1381339242-32030-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50175 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279Ab3JISCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 14:02:47 -0400
In-Reply-To: <1381339242-32030-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Wed, 9 Oct 2013 20:20:40 +0300

> A002 is still in "no plans to fix" state, and applies to all
> the current P1/P2 parts as well, so it's resonable to enable
> its workaround by default, for all the soc's with etsec.
> The impact of not enabling this workaround for affected parts
> is that under certain conditons (runt frames or even frames
> with RX error detected at PHY level) during controller reset,
> the controller might fail to indicate Rx reset (GRS) completion.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied.
