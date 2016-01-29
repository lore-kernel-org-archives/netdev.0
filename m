From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] xen-netfront: request Tx response events more
 often
Date: Thu, 28 Jan 2016 16:09:31 -0800 (PST)
Message-ID: <20160128.160931.2281411720894108965.davem@davemloft.net>
References: <1453828364-2042-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	malcolm.crossley@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60053 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbcA2AJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 19:09:32 -0500
In-Reply-To: <1453828364-2042-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Tue, 26 Jan 2016 17:12:44 +0000

> From: Malcolm Crossley <malcolm.crossley@citrix.com>
> 
> Trying to batch Tx response events results in poor performance because
> this delays freeing the transmitted skbs.
> 
> Instead use the standard RING_FINAL_CHECK_FOR_RESPONSES() macro to be
> notified once the next Tx response is placed on the ring.
> 
> Signed-off-by: Malcolm Crossley <malcolm.crossley@citrix.com>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Applied.
