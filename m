From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "usbnet: drop unneeded check for NULL"
Date: Wed, 05 Sep 2012 16:20:46 -0400 (EDT)
Message-ID: <20120905.162046.1293290557238046936.davem@davemloft.net>
References: <1346872952-21192-1-git-send-email-oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oneukum@suse.de
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44391 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753743Ab2IEUUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 16:20:52 -0400
In-Reply-To: <1346872952-21192-1-git-send-email-oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>
Date: Wed,  5 Sep 2012 21:22:32 +0200

> This reverts commit 5d65878d7031b6c39054b282faceff406bb2fda9.
> The upper layers call usbnet_start_xmit() with a valid skb.
> However cdc_ncm abuses this method by calling it with NULL
> to trigger IO for the aggregated private skb holding erlier
> packets. Until cdc_ncm is fixed, the check for NULL must
> be reintroduced.
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>

Applied, thanks Oliver.
