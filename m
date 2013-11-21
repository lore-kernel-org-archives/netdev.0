From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net] xen-netback: stop the VIF thread before
 unbinding IRQs
Date: Thu, 21 Nov 2013 13:17:51 -0500 (EST)
Message-ID: <20131121.131751.1231978152112137182.davem@davemloft.net>
References: <1385047569-23622-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, konrad.wilk@oracle.com,
	boris.ostrovsky@oracle.com, ian.campbell@citrix.com,
	wei.liu2@citrix.com, netdev@vger.kernel.org
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754044Ab3KUSRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 13:17:52 -0500
In-Reply-To: <1385047569-23622-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Thu, 21 Nov 2013 15:26:09 +0000

> From: David Vrabel <david.vrabel@citrix.com>
> 
> If the VIF thread is still running after unbinding the Tx and Rx IRQs
> in xenvif_disconnect(), the thread may attempt to raise an event which
> will BUG (as the irq is unbound).
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Applied.
