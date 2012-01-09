From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 8139cp: fix missing napi_gro_flush.
Date: Sun, 08 Jan 2012 19:21:08 -0800 (PST)
Message-ID: <20120108.192108.1050572683606841194.davem@davemloft.net>
References: <20120108234133.GA2785@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zhilla2@gmail.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57387 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755164Ab2AIDWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2012 22:22:15 -0500
In-Reply-To: <20120108234133.GA2785@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Mon, 9 Jan 2012 00:41:33 +0100

> The driver uses __napi_complete and napi_gro_receive. Without it, the
> driver hits the BUG_ON(n->gro_list) assertion hard in __napi_complete.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Tested-by: Marin Glibic <zhilla2@gmail.com>

Applied, thanks.

> ---
> 
>  This is a candidate for -stable.

Queued up.
