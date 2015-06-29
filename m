From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: don't access RACC register when not available
Date: Sun, 28 Jun 2015 17:02:51 -0700 (PDT)
Message-ID: <20150628.170251.1472757458531380273.davem@davemloft.net>
References: <201506260510.t5Q5AZ90010455@goober.accelecon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gerg@uclinux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752967AbbF2ACw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 20:02:52 -0400
In-Reply-To: <201506260510.t5Q5AZ90010455@goober.accelecon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Ungerer <gerg@uclinux.org>
Date: Fri, 26 Jun 2015 15:10:35 +1000

> From 8969de63989b8814a6db9d00b9d1ceabe40e8b11 Mon Sep 17 00:00:00 2001
> From: Greg Ungerer <gerg@uclinux.org>
> Date: Sat, 20 Jun 2015 15:51:57 +1000
> Subject: [PATCH] net: fec: don't access RACC register when not available
> 
> Not all silicon implementations of the Freescale FEC hardware module
> have the RACC (Receive Accelerator Function) register, so we should not
> be trying to access it on those that don't. Currently none of the ColdFire
> based parts with a FEC have it.
> 
> Support for RACC was introduced by commit 4c09eed9 ("net: fec: Enable imx6
> enet checksum acceleration"). A fix was introduced in commit d1391930
> ("net: fec: Fix build for MCF5272") that disables its use on the ColdFire
> M5272 part, but it doesn't fix the general case of other ColdFire parts.
> 
> To fix we create a quirk flag, FEC_QUIRK_HAS_RACC, and check it before
> working with the RACC register.
> 
> Signed-off-by: Greg Ungerer <gerg@uclinux.org>

Applied, thank you.
