From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net] xen-netback: release pending index before
 pushing Tx responses
Date: Tue, 24 Feb 2015 16:24:43 -0500 (EST)
Message-ID: <20150224.162443.2047866685711544650.davem@davemloft.net>
References: <1424776679-7509-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	ian.campbell@citrix.com, wei.liu2@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51145 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbbBXVYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 16:24:46 -0500
In-Reply-To: <1424776679-7509-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Tue, 24 Feb 2015 11:17:59 +0000

> If the pending indexes are released /after/ pushing the Tx response
> then a stale pending index may be used if a new Tx request is
> immediately pushed by the frontend.  The may cause various WARNINGs or
> BUGs if the stale pending index is actually still in use.
> 
> Fix this by releasing the pending index before pushing the Tx
> response.
> 
> The full barrier for the pending ring update is not required since the
> the Tx response push already has a suitable write barrier.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Applied, thanks David.
