From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2][Nios2-dev] Altera TSE: Add missing phydev
Date: Fri, 02 Jan 2015 16:26:21 -0500 (EST)
Message-ID: <20150102.162621.303781806493395538.davem@davemloft.net>
References: <SNT146-W41ED8A3C5CE762B5F35C15B65D0@phx.gbl>
	<20150102.160703.2063675003050187496.davem@davemloft.net>
	<SNT146-W703EA22E7BC894479746F0B65D0@phx.gbl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nios2-dev@lists.rocketboards.org, netdev@vger.kernel.org
To: bkostya@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53606 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbbABV0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 16:26:23 -0500
In-Reply-To: <SNT146-W703EA22E7BC894479746F0B65D0@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kostya Belezko <bkostya@hotmail.com>
Date: Fri, 2 Jan 2015 16:16:34 -0500

> Yes, this is what the patch intends to achieve. It keeps phydev
> non-NULL and calls phy_stop, shy_start respectively.  phy_disconnect
> is called upon rmmod.

Aha, ok I see.  Looks good to me.
