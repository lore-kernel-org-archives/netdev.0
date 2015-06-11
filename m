From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ps3_gelic: Fix build error with DEBUG
Date: Thu, 11 Jun 2015 00:38:28 -0700 (PDT)
Message-ID: <20150611.003828.2049980814236928899.davem@davemloft.net>
References: <1433956788.4524.15.camel@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	cbe-oss-dev@lists.ozlabs.org
To: geoff@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58860 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbbFKHi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 03:38:28 -0400
In-Reply-To: <1433956788.4524.15.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geoff Levand <geoff@infradead.org>
Date: Wed, 10 Jun 2015 10:19:48 -0700

> When the DEBUG preprocessor macro is defined the ps3_gelic_net driver build
> fails due to an undeclared routine gelic_descr_get_status().  This problem
> was introduced during the code cleanup of commit
> 6b0c21cede22be1f68f0a632c0ca38008ce1abe7 (net: Fix p3_gelic_net sparse warnings),
> which re-arranged the ordering of some of the gelic routines.
> 
> This change just moves the gelic_descr_get_status() routine up in the
> ps3_gelic_net.c source file. There is no functional change.
> 
> Fixes build errors like these:
> 
>   drivers/net/ethernet/toshiba/ps3_gelic_net.c: error: implicit declaration of function gelic_descr_get_status
> 
> Signed-off-by: Geoff Levand <geoff@infradead.org>

Applied, thanks.
