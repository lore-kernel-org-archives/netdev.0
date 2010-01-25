From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns xfrm: deal with dst entries in netns
Date: Sun, 24 Jan 2010 22:48:06 -0800 (PST)
Message-ID: <20100124.224806.58429357.davem@davemloft.net>
References: <20100124154014.GA6124@x200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49094
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752600Ab0AYGry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 01:47:54 -0500
In-Reply-To: <20100124154014.GA6124@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sun, 24 Jan 2010 17:40:14 +0200

> GC is non-existent in netns, so after you hit GC threshold, no new
> dst entries will be created until someone triggers cleanup in init_net.
> 
> Make xfrm4_dst_ops and xfrm6_dst_ops per-netns.
> This is not done in a generic way, because it woule waste
> (AF_MAX - 2) * sizeof(struct dst_ops) bytes per-netns.
> 
> Reorder GC threshold initialization so it'd be done before registering
> XFRM policies.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks Alexey.
