From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net] xen-netfront: handle backend CLOSED without
 CLOSING
Date: Tue, 04 Feb 2014 20:43:00 -0800 (PST)
Message-ID: <20140204.204300.1246992450475475633.davem@davemloft.net>
References: <1391539826-30962-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, konrad.wilk@oracle.com,
	boris.ostrovsky@oracle.com, netdev@vger.kernel.org
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48928 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754626AbaBEEnB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 23:43:01 -0500
In-Reply-To: <1391539826-30962-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Tue, 4 Feb 2014 18:50:26 +0000

> From: David Vrabel <david.vrabel@citrix.com>
> 
> Backend drivers shouldn't transistion to CLOSED unless the frontend is
> CLOSED.  If a backend does transition to CLOSED too soon then the
> frontend may not see the CLOSING state and will not properly shutdown.
> 
> So, treat an unexpected backend CLOSED state the same as CLOSING.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Applied, thanks.
