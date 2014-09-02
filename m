From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Fix initialization of the wrong spin lock
Date: Tue, 02 Sep 2014 14:03:57 -0700 (PDT)
Message-ID: <20140902.140357.1163159067252068258.davem@davemloft.net>
References: <20140902144022.10877.58098.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58644 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754889AbaIBVD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 17:03:58 -0400
In-Reply-To: <20140902144022.10877.58098.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 2 Sep 2014 09:40:22 -0500

> During allocation and initialization of the network driver structures,
> the wrong pointer is used to initialize a spin lock. Fix the spin lock
> initialization by using the proper pointer.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>

Applied, thanks.
