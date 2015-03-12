From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net] xen-netback: notify immediately after pushing Tx
 response.
Date: Wed, 11 Mar 2015 23:31:27 -0400 (EDT)
Message-ID: <20150311.233127.1616833687415787157.davem@davemloft.net>
References: <1426087679-13927-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	ian.campbell@citrix.com, wei.liu2@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55867 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbbCLDba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 23:31:30 -0400
In-Reply-To: <1426087679-13927-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Wed, 11 Mar 2015 15:27:59 +0000

> This fixes a performance regression introduced by
> 7fbb9d8415d4a51cf542e87cf3a717a9f7e6aedc (xen-netback: release pending
> index before pushing Tx responses)
> 
> Moving the notify outside of the spin locks means it can be delayed a
> long time (if the dealloc thread is descheduled or there is an
> interrupt or softirq).
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Applied, thanks David.
