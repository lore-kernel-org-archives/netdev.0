From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] fec: fix clk handling for Coldfire.
Date: Sun, 17 Jun 2012 16:47:04 -0700 (PDT)
Message-ID: <20120617.164704.225704951627971907.davem@davemloft.net>
References: <201206171639.43651.sfking@fdwdc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sfking@fdwdc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38147 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951Ab2FQXrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jun 2012 19:47:04 -0400
In-Reply-To: <201206171639.43651.sfking@fdwdc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven King <sfking@fdwdc.com>
Date: Sun, 17 Jun 2012 16:39:43 -0700

> commit f4d40de39a23f0c39cca55ac63e1175c69c3d2f7
> 'net fec: do not depend on grouped clocks' broke fec for Coldfire.
> 
> Hide the details of the fec clk management in a trio of new functions: 
> fec_clk_get, fec_clk_prepare and fec_clk_disable_unprepare.  these then can 
> be modified as needed to manage the clks for the different arches that use
> the fec controller.
> 
> Signed-off-by: Steven King <sfking@fdwdc.com>

I said keep the ifdefs out of the foo.c code.

Put this ifdef'y into one of the driver's header files, such
as fec.h
