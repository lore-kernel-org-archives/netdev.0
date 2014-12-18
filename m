From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] geneve: Remove socket and offload handlers at
 destruction.
Date: Thu, 18 Dec 2014 12:38:47 -0500 (EST)
Message-ID: <20141218.123847.1189808279501784507.davem@davemloft.net>
References: <1418783132-99230-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, azhou@nicira.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46999 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbaLRRit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 12:38:49 -0500
In-Reply-To: <1418783132-99230-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Tue, 16 Dec 2014 18:25:31 -0800

> Sockets aren't currently removed from the the global list when
> they are destroyed. In addition, offload handlers need to be cleaned
> up as well.
> 
> Fixes: 0b5e8b8e ("net: Add Geneve tunneling protocol driver")
> CC: Andy Zhou <azhou@nicira.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied.
