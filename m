From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/4] ipv4: Update pmtu informations on inetpeer only
 for output routes
Date: Wed, 9 Nov 2011 13:11:20 +0100
Message-ID: <20111109121120.GB10138@secunet.com>
References: <20111011110842.GC1830@secunet.com>
 <20111011111027.GE1830@secunet.com>
 <20111012.170805.2172804476308993385.davem@davemloft.net>
 <20111108.143630.106539981030509701.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39147 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751150Ab1KIMLY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 07:11:24 -0500
Content-Disposition: inline
In-Reply-To: <20111108.143630.106539981030509701.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 08, 2011 at 02:36:30PM -0500, David Miller wrote:
> 
> What I think you can do to solve this problem is explicitly use
> dst->ops->default_mtu() in ip_forward() instead of dst_mtu().
> 
> That way you won't use the cached PMTU for input routes.

Yes, I already had something like that in mind. I'll do
a patch to fix it in this manner.
