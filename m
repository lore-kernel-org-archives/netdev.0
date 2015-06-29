From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Add the __GFP_NOWARN flag to Rx buffer
 allocation
Date: Mon, 29 Jun 2015 09:27:22 -0700 (PDT)
Message-ID: <20150629.092722.310092810741640306.davem@davemloft.net>
References: <20150629162212.20833.16427.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159AbbF2Q1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 12:27:23 -0400
In-Reply-To: <20150629162212.20833.16427.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Mon, 29 Jun 2015 11:22:12 -0500

> When allocating Rx related buffers, alloc_pages is called using an order
> number that is decreased until successful. A system under stress can
> experience failures during this allocation process resulting in a warning
> being issued. This message can be of concern to end users even though the
> failure is not fatal. Since the failure is not fatal and can occur
> multiple times, the driver should include the __GFP_NOWARN flag to
> suppress the warning message from being issued.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied, thanks.
