From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Export __netdev_pick_tx so that it can be used in
 modules
Date: Fri, 11 Jan 2013 15:47:40 -0800 (PST)
Message-ID: <20130111.154740.1605307304265175473.davem@davemloft.net>
References: <20130111183842.6152.34578.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48377 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754832Ab3AKXrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 18:47:47 -0500
In-Reply-To: <20130111183842.6152.34578.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Fri, 11 Jan 2013 10:38:42 -0800

> When testing with FCoE enabled we discovered that I had not exported
> __netdev_pick_tx.  As a result ixgbe doesn't build with the RFC patches
> applied because ixgbe_select_queue was calling the function.  This change
> corrects that build issue by correctly exporting __netdev_pick_tx so it
> can be used by modules.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied.
